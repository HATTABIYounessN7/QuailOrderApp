package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strings"
	"sync"
	"time"
)

// ── Valid statuses ────────────────────────────────────────────────────────────

var validStatuses = map[string]bool{
	"pending":   true,
	"confirmed": true,
	"in_route":  true,
	"delivered": true,
	"cancelled": true,
}

// ── Models ────────────────────────────────────────────────────────────────────

type Product struct {
	ID          string  `json:"id"`
	Name        string  `json:"name"`
	Description string  `json:"description"`
	Price       float64 `json:"price"`
	Category    string  `json:"category"`
	ImageURL    string  `json:"imageUrl"`
	InStock     bool    `json:"inStock"`
	StockCount  int     `json:"stockCount"`
	Unit        string  `json:"unit"`
}

// UserResponse omits the password field from API responses.
type UserResponse struct {
	ID      string `json:"id"`
	Name    string `json:"name"`
	Email   string `json:"email"`
	Role    string `json:"role"`
	Phone   string `json:"phone"`
	Address string `json:"address"`
}

type User struct {
	ID       string `json:"id"`
	Name     string `json:"name"`
	Email    string `json:"email"`
	Password string `json:"password"`
	Role     string `json:"role"`
	Phone    string `json:"phone"`
	Address  string `json:"address"`
}

type OrderItem struct {
	ProductID   string  `json:"productId"`
	ProductName string  `json:"productName"`
	UnitPrice   float64 `json:"unitPrice"`
	Quantity    int     `json:"quantity"`
	Unit        string  `json:"unit"`
}

type Order struct {
	ID              string      `json:"id"`
	UserID          string      `json:"userId"`
	CustomerName    string      `json:"customerName"`
	DeliveryAddress string      `json:"deliveryAddress"`
	Phone           string      `json:"phone"`
	Items           []OrderItem `json:"items"`
	PlacedAt        time.Time   `json:"placedAt"`
	Status          string      `json:"status"`
	UpdatedAt       *time.Time  `json:"updatedAt"`
}

// ── In-memory stores ──────────────────────────────────────────────────────────

var (
	products   []Product
	productsMu sync.RWMutex

	orders   []Order
	ordersMu sync.RWMutex

	users []User // read-only after init
)

func init() {
	products = []Product{
		{
			ID:          "q_001",
			Name:        "Live Japanese Quail",
			Description: "Healthy, farm-raised Japanese quail (Coturnix coturnix japonica). Ready for laying or meat production. Vaccinated and well-fed.",
			Price:       35.00,
			Category:    "quail",
			ImageURL:    "https://upload.wikimedia.org/wikipedia/commons/8/8d/Coturnix_coturnix_%28Lmbuga%29_%28cropped%29.jpg?_=20180905162423",
			InStock:     true,
			StockCount:  40,
			Unit:        "per bird",
		},
		{
			ID:          "q_002",
			Name:        "Laying Quail Hen",
			Description: "Female quail selected for high egg production. Approx. 280-300 eggs per year. Age: 6-8 weeks.",
			Price:       50.00,
			Category:    "quail",
			ImageURL:    "https://upload.wikimedia.org/wikipedia/commons/8/8d/Coturnix_coturnix_%28Lmbuga%29_%28cropped%29.jpg?_=20180905162423",
			InStock:     true,
			StockCount:  20,
			Unit:        "per bird",
		},
		{
			ID:          "q_003",
			Name:        "Quail Pair (1M + 1F)",
			Description: "One male and one female Japanese quail. Perfect for starting your own small flock.",
			Price:       90.00,
			Category:    "quail",
			ImageURL:    "https://upload.wikimedia.org/wikipedia/commons/8/8d/Coturnix_coturnix_%28Lmbuga%29_%28cropped%29.jpg?_=20180905162423",
			InStock:     true,
			StockCount:  10,
			Unit:        "per pair",
		},
		{
			ID:          "e_001",
			Name:        "Fresh Quail Eggs — Dozen",
			Description: "Farm-fresh quail eggs, collected daily. Rich in protein and vitamins. Perfect for cooking or snacking.",
			Price:       12.00,
			Category:    "eggs",
			ImageURL:    "https://images.unsplash.com/photo-1645218167737-7e9c23137641?w=400&auto=format&fm=png",
			InStock:     true,
			StockCount:  200,
			Unit:        "per dozen (12)",
		},
		{
			ID:          "e_002",
			Name:        "Fresh Quail Eggs — Tray",
			Description: "Economy tray of 30 fresh quail eggs. Best value for families and small restaurants.",
			Price:       28.00,
			Category:    "eggs",
			ImageURL:    "https://images.unsplash.com/photo-1645218167737-7e9c23137641?w=400&auto=format&fm=png",
			InStock:     true,
			StockCount:  150,
			Unit:        "per tray (30)",
		},
		{
			ID:          "e_003",
			Name:        "Hatching Eggs — Dozen",
			Description: "Fertilised quail eggs ready for incubation. High hatch rate (~85%). Stored and handled with care.",
			Price:       20.00,
			Category:    "eggs",
			ImageURL:    "https://images.unsplash.com/photo-1645218167737-7e9c23137641?w=400&auto=format&fm=png",
			InStock:     false,
			StockCount:  0,
			Unit:        "per dozen (12)",
		},
	}

	users = []User{
		{ID: "admin1", Name: "Admin", Email: "admin@test.com", Password: "1234", Role: "admin", Phone: "+212600000000", Address: "Quail Store, City1"},
		{ID: "user1", Name: "Youssef Nazih", Email: "youssef.nazih@test.com", Password: "1234", Role: "customer", Phone: "+212611111111", Address: "123 Rue1, City1"},
		{ID: "user2", Name: "Youssef Rahioui", Email: "youssef.rahioui@test.com", Password: "1234", Role: "customer", Phone: "+212622222222", Address: "123 Rue1, City2"},
	}

	t1 := time.Date(2026, 5, 12, 10, 30, 0, 0, time.UTC)
	t1u := time.Date(2026, 5, 12, 16, 0, 0, 0, time.UTC)
	t2 := time.Date(2026, 5, 13, 14, 0, 0, 0, time.UTC)
	t2u := time.Date(2026, 5, 13, 15, 0, 0, 0, time.UTC)
	t3 := time.Date(2026, 5, 14, 8, 0, 0, 0, time.UTC)

	orders = []Order{
		{
			ID:              "1715508600000",
			UserID:          "user1",
			CustomerName:    "Youssef Nazih",
			DeliveryAddress: "123 Rue1, City1",
			Phone:           "+212611111111",
			Items: []OrderItem{
				{ProductID: "e_001", ProductName: "Fresh Quail Eggs — Dozen", UnitPrice: 12.00, Quantity: 2, Unit: "per dozen (12)"},
				{ProductID: "e_002", ProductName: "Fresh Quail Eggs — Tray", UnitPrice: 28.00, Quantity: 1, Unit: "per tray (30)"},
			},
			PlacedAt:  t1,
			Status:    "delivered",
			UpdatedAt: &t1u,
		},
		{
			ID:              "1715594400000",
			UserID:          "user2",
			CustomerName:    "Youssef Rahioui",
			DeliveryAddress: "123 Rue1, City2",
			Phone:           "+212622222222",
			Items: []OrderItem{
				{ProductID: "q_001", ProductName: "Live Japanese Quail", UnitPrice: 35.00, Quantity: 3, Unit: "per bird"},
			},
			PlacedAt:  t2,
			Status:    "confirmed",
			UpdatedAt: &t2u,
		},
		{
			ID:              "1715659200000",
			UserID:          "user1",
			CustomerName:    "Youssef Nazih",
			DeliveryAddress: "123 Rue1, City1",
			Phone:           "+212611111111",
			Items: []OrderItem{
				{ProductID: "q_002", ProductName: "Laying Quail Hen", UnitPrice: 50.00, Quantity: 2, Unit: "per bird"},
			},
			PlacedAt:  t3,
			Status:    "pending",
			UpdatedAt: nil,
		},
	}
}

// ── Helpers ───────────────────────────────────────────────────────────────────

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(v)
}

func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PATCH, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type")
		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusNoContent)
			return
		}
		next.ServeHTTP(w, r)
	})
}

func loggingMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		next.ServeHTTP(w, r)
		log.Printf("%-6s %s  %s", r.Method, r.URL.RequestURI(), time.Since(start))
	})
}

// ── Handlers ──────────────────────────────────────────────────────────────────

// GET /api/products?category=
func handleProducts(w http.ResponseWriter, r *http.Request) {
	productsMu.RLock()
	defer productsMu.RUnlock()

	category := r.URL.Query().Get("category")
	if category == "" || category == "all" {
		writeJSON(w, http.StatusOK, products)
		return
	}
	result := []Product{}
	for _, p := range products {
		if p.Category == category {
			result = append(result, p)
		}
	}
	writeJSON(w, http.StatusOK, result)
}

// GET /api/products/{id}
func handleProductByID(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	productsMu.RLock()
	defer productsMu.RUnlock()
	for _, p := range products {
		if p.ID == id {
			writeJSON(w, http.StatusOK, p)
			return
		}
	}
	writeJSON(w, http.StatusNotFound, map[string]string{"error": "product not found"})
}

// POST /api/auth/login
func handleLogin(w http.ResponseWriter, r *http.Request) {
	var creds struct {
		Email    string `json:"email"`
		Password string `json:"password"`
	}
	if err := json.NewDecoder(r.Body).Decode(&creds); err != nil {
		writeJSON(w, http.StatusBadRequest, map[string]string{"error": "invalid JSON"})
		return
	}
	if creds.Email == "" || creds.Password == "" {
		writeJSON(w, http.StatusBadRequest, map[string]string{"error": "email and password are required"})
		return
	}
	email := strings.ToLower(strings.TrimSpace(creds.Email))
	password := strings.TrimSpace(creds.Password)
	for _, u := range users {
		if u.Email == email && u.Password == password {
			writeJSON(w, http.StatusOK, UserResponse{
				ID:      u.ID,
				Name:    u.Name,
				Email:   u.Email,
				Role:    u.Role,
				Phone:   u.Phone,
				Address: u.Address,
			})
			return
		}
	}
	writeJSON(w, http.StatusUnauthorized, map[string]string{"error": "invalid credentials"})
}

// GET /api/users/{id}
func handleUserByID(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	for _, u := range users {
		if u.ID == id {
			writeJSON(w, http.StatusOK, UserResponse{
				ID:      u.ID,
				Name:    u.Name,
				Email:   u.Email,
				Role:    u.Role,
				Phone:   u.Phone,
				Address: u.Address,
			})
			return
		}
	}
	writeJSON(w, http.StatusNotFound, map[string]string{"error": "user not found"})
}

// GET /api/orders?userId=&status=
func handleGetOrders(w http.ResponseWriter, r *http.Request) {
	ordersMu.RLock()
	defer ordersMu.RUnlock()

	userID := r.URL.Query().Get("userId")
	status := r.URL.Query().Get("status")

	// Validate status filter if provided
	if status != "" && !validStatuses[status] {
		writeJSON(w, http.StatusBadRequest, map[string]string{
			"error": "invalid status — must be one of: pending, confirmed, in_route, delivered, cancelled",
		})
		return
	}

	result := []Order{}
	for _, o := range orders {
		if userID != "" && o.UserID != userID {
			continue
		}
		if status != "" && o.Status != status {
			continue
		}
		result = append(result, o)
	}
	writeJSON(w, http.StatusOK, result)
}

// GET /api/orders/{id}
func handleOrderByID(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	ordersMu.RLock()
	defer ordersMu.RUnlock()
	for _, o := range orders {
		if o.ID == id {
			writeJSON(w, http.StatusOK, o)
			return
		}
	}
	writeJSON(w, http.StatusNotFound, map[string]string{"error": "order not found"})
}

// POST /api/orders
func handleCreateOrder(w http.ResponseWriter, r *http.Request) {
	var order Order
	if err := json.NewDecoder(r.Body).Decode(&order); err != nil {
		writeJSON(w, http.StatusBadRequest, map[string]string{"error": "invalid request body: " + err.Error()})
		return
	}

	// Required field validation
	if order.ID == "" || order.UserID == "" || order.CustomerName == "" || len(order.Items) == 0 {
		writeJSON(w, http.StatusBadRequest, map[string]string{"error": "id, userId, customerName and items are required"})
		return
	}
	if order.DeliveryAddress == "" {
		writeJSON(w, http.StatusBadRequest, map[string]string{"error": "deliveryAddress is required"})
		return
	}
	if order.Phone == "" {
		writeJSON(w, http.StatusBadRequest, map[string]string{"error": "phone is required"})
		return
	}

	// Per-item validation
	for _, item := range order.Items {
		if item.ProductID == "" {
			writeJSON(w, http.StatusBadRequest, map[string]string{"error": "each item must have a productId"})
			return
		}
		if item.Quantity <= 0 {
			writeJSON(w, http.StatusBadRequest, map[string]string{"error": "item quantity must be greater than 0"})
			return
		}
	}

	// Status validation
	if order.Status == "" {
		order.Status = "pending"
	} else if !validStatuses[order.Status] {
		writeJSON(w, http.StatusBadRequest, map[string]string{"error": "invalid status"})
		return
	}
	if order.PlacedAt.IsZero() {
		order.PlacedAt = time.Now().UTC()
	}

	// Stock availability check
	productsMu.RLock()
	for _, item := range order.Items {
		found := false
		for _, p := range products {
			if p.ID == item.ProductID {
				found = true
				if !p.InStock || p.StockCount < item.Quantity {
					productsMu.RUnlock()
					writeJSON(w, http.StatusConflict, map[string]string{
						"error": fmt.Sprintf("insufficient stock for \"%s\" (available: %d)", p.Name, p.StockCount),
					})
					return
				}
				break
			}
		}
		if !found {
			productsMu.RUnlock()
			writeJSON(w, http.StatusBadRequest, map[string]string{
				"error": fmt.Sprintf("product \"%s\" not found", item.ProductID),
			})
			return
		}
	}
	productsMu.RUnlock()

	// Reject duplicate order IDs
	ordersMu.Lock()
	for _, o := range orders {
		if o.ID == order.ID {
			ordersMu.Unlock()
			writeJSON(w, http.StatusConflict, map[string]string{"error": "order id already exists"})
			return
		}
	}
	orders = append([]Order{order}, orders...) // newest first
	ordersMu.Unlock()

	// Decrement stock after order is committed
	productsMu.Lock()
	for i := range products {
		for _, item := range order.Items {
			if products[i].ID == item.ProductID {
				products[i].StockCount -= item.Quantity
				if products[i].StockCount <= 0 {
					products[i].StockCount = 0
					products[i].InStock = false
				}
				break
			}
		}
	}
	productsMu.Unlock()

	writeJSON(w, http.StatusCreated, order)
}

// PATCH /api/orders/{id}/status
func handleUpdateStatus(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	var body struct {
		Status string `json:"status"`
	}
	if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
		writeJSON(w, http.StatusBadRequest, map[string]string{"error": "invalid request body: " + err.Error()})
		return
	}
	if body.Status == "" {
		writeJSON(w, http.StatusBadRequest, map[string]string{"error": "status is required"})
		return
	}
	if !validStatuses[body.Status] {
		writeJSON(w, http.StatusBadRequest, map[string]string{
			"error": "invalid status — must be one of: pending, confirmed, in_route, delivered, cancelled",
		})
		return
	}
	now := time.Now().UTC()
	ordersMu.Lock()
	defer ordersMu.Unlock()
	for i, o := range orders {
		if o.ID == id {
			orders[i].Status = body.Status
			orders[i].UpdatedAt = &now
			writeJSON(w, http.StatusOK, orders[i])
			return
		}
	}
	writeJSON(w, http.StatusNotFound, map[string]string{"error": "order not found"})
}

// ── Main ──────────────────────────────────────────────────────────────────────

func main() {
	mux := http.NewServeMux()

	mux.HandleFunc("GET /api/products", handleProducts)
	mux.HandleFunc("GET /api/products/{id}", handleProductByID)
	mux.HandleFunc("POST /api/auth/login", handleLogin)
	mux.HandleFunc("GET /api/users/{id}", handleUserByID)
	mux.HandleFunc("GET /api/orders", handleGetOrders)
	mux.HandleFunc("GET /api/orders/{id}", handleOrderByID)
	mux.HandleFunc("POST /api/orders", handleCreateOrder)
	mux.HandleFunc("PATCH /api/orders/{id}/status", handleUpdateStatus)

	log.Println("Quail backend listening on :8080")
	log.Fatal(http.ListenAndServe(":8080", loggingMiddleware(corsMiddleware(mux))))
}
