import 'dart:convert';
import 'dart:ffi';
import 'package:http/http.dart' as http;

import 'package:flutter/widgets.dart';

import 'package:shop_zone/providers/cart.dart';

import '../constants.dart';

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

  Future<Void> fetchOrders() async {
    const url = '${Constants.baseUrl}/orders.json';
    try {
      final response = await http.get(url);
      final result = json.decode(response.body) as Map<String, dynamic>;
      final List<OrderItem> list = [];

      if (result != null && result.isNotEmpty) {
        result.forEach((key, val) {
          val['id'] = key;
          list.add(OrderItem.fromMap(val));
        });

        _orders = list.reversed.toList();
        notifyListeners();
      }
    } catch (err) {
      print(err);
      throw (err);
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    const url = '${Constants.baseUrl}/orders.json';

    try {
      final timestamp = DateTime.now();
      final response = await http.post(
        url,
        body: json.encode({
          'amount': total,
          'items': cartProducts.map((x) => x.toMap()).toList(),
          'dateTime': timestamp.millisecondsSinceEpoch,
        }),
      );

      _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          items: cartProducts,
          dateTime: timestamp,
        ),
      );
      notifyListeners();
    } catch (error) {
      // can write logic like sending the error to server for analytics
      print(error);
      throw error;
    }
  }
}
