import 'dart:convert';

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'items': List<dynamic>.from(items.map((x) => x.toMap())),
      'dateTime': dateTime.millisecondsSinceEpoch,
    };
  }

  static OrderItem fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
  
    return OrderItem(
      id: map['id'],
      amount: map['amount'],
      items: List<CartItem>.from(map['items']?.map((x) => CartItem.fromMap(x))),
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime']),
    );
  }

  String toJson() => json.encode(toMap());

  static OrderItem fromJson(String source) => fromMap(json.decode(source));
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
