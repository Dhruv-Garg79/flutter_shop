import 'package:flutter/widgets.dart';
import 'package:shop_zone/providers/cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> items;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.items,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  void addOrder(List<CartItem> cartProducts, double total) {
    _orders.insert(
      0,
      OrderItem(
        id: DateTime.now().toString(),
        amount: total,
        items: cartProducts,
        dateTime: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
