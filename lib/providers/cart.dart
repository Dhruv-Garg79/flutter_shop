import 'dart:convert';

import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String title;
  final String desc;
  final int quantity;
  final double price;
  final String imageUrl;

  CartItem(
      this.id, this.title, this.desc, this.quantity, this.price, this.imageUrl);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'desc': desc,
      'quantity': quantity,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  static CartItem fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
  
    return CartItem(
      map['id'],
      map['title'],
      map['desc'],
      map['quantity'],
      map['price'],
      map['imageUrl'],
    );
  }

  String toJson() => json.encode(toMap());

  static CartItem fromJson(String source) => fromMap(json.decode(source));
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  List<CartItem> get itemValues {
    return {..._items}.values.toList();
  }
  
  List<String> get itemKeys {
    return {..._items}.keys.toList();
  }

  int get itemCount => _items.length;

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, item) {
      total += item.quantity * item.price;
    });
    return total;
  }

  void addItem(
      String productId, String title, String desc, double price, String image) {
    if (_items.containsKey(productId)) {
      _items.update(
          productId,
          (existingItem) => CartItem(
              existingItem.id,
              existingItem.title,
              existingItem.desc,
              existingItem.quantity + 1,
              existingItem.price,
              existingItem.imageUrl));
    } else {
      _items.putIfAbsent(
          productId,
          () => CartItem(
              DateTime.now().toString(), title, desc, 1, price, image));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId){
    if(_items[productId].quantity > 1)
      decrementQuantityFor(productId);
    else
      removeItem(productId);
  }

  void incrementQuantityFor(String productId) {
    _items.update(
      productId,
      (existingItem) => CartItem(
        existingItem.id,
        existingItem.title,
        existingItem.desc,
        existingItem.quantity + 1,
        existingItem.price,
        existingItem.imageUrl,
      ),
    );
    notifyListeners();
  }

  void decrementQuantityFor(String productId) {
    CartItem c = _items[productId];
    if (c != null && c.quantity > 1) {
      _items.update(
        productId,
        (existingItem) => CartItem(
          existingItem.id,
          existingItem.title,
          existingItem.desc,
          existingItem.quantity - 1,
          existingItem.price,
          existingItem.imageUrl,
        ),
      );
      notifyListeners();
    }
  }

  void clear(){
    _items = {};
    notifyListeners();
  }
}
