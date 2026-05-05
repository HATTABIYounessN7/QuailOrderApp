import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quail_order_app/features/admin/screens/admin_orders_screen.dart';
import 'package:quail_order_app/features/auth/controllers/auth_controller.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: const AdminOrdersScreen(),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will be returned to the login screen.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              AuthController.to.logout();
            },
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}
