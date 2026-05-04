import 'package:quail_order_app/data/models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;

  Map<String, dynamic> toJson() => {
    'productId': product.id,
    'quantity': quantity,
  };
}
