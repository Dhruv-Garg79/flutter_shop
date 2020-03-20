import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shop_zone/constants.dart';
import 'package:shop_zone/models/http_exception.dart';
import 'package:shop_zone/providers/product.dart';

class Products with ChangeNotifier {

  List<Product> _items = [];

  final String authToken;
  final String userId;

  Products(this.authToken, this._items, this.userId);

  List<Product> get favItems {
    return _items.where((pro) => pro.isFavorite).toList();
  }

  List<Product> get items {
    return [..._items];
  }

  Product getProductById(String id) {
    return _items.firstWhere((pro) => pro.id == id);
  }

  Future<void> fetchProducts([bool filterByUser = false]) async {
    final filter = filterByUser == true ? '&orderBy="creatorId"&equalTo="$userId"' : '';
    final url = '${Constants.baseUrl}/products.json?auth=$authToken$filter';
    final favUrl = '${Constants.baseUrl}/favProducts/$userId.json?auth=$authToken';

    try {
      final response = await http.get(url);
      final favResponse = await http.get(favUrl);
      final data = json.decode(response.body) as Map<String, dynamic>;
      final favData = json.decode(favResponse.body) as Map<String, dynamic>;

      List<Product> loadedItems = [];
      data.forEach((key, map) {
        loadedItems.add(Product(
          id: key,
          title: map['title'],
          description: map['description'],
          price: map['price'],
          imageUrl: map['imageUrl'],
          isFavorite: favData == null ? false : favData[key] ?? false,
        ));
      });

      _items = loadedItems;
      notifyListeners();
    } catch (error) {
      print(error.toString());
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = '${Constants.baseUrl}/products.json?auth=$authToken';

    try {
      final response = await http.post(url, body: {
        "title": product.title,
        "description": product.description,
        "price": product.price,
        "imageUrl": product.imageUrl,
        "creatorId": userId
      });

      Product newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );

      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      // can write logic like sending the error to server for analytics
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(Product product) async {
    final index = _items.indexWhere((test) => test.id == product.id);
    if (index >= 0) {
      try {
        final url = '${Constants.baseUrl}/products/${product.id}.json';
        await http.patch(url, body: product.toJson());

        _items[index] = product;
        notifyListeners();
      } catch (error) {
        print(error);
        throw error;
      }
    }
  }

  Future<void> removeProduct(String id) async {
    final existingProductIndex = _items.indexWhere((test) => test.id == id);
    final existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();

    final url = '${Constants.baseUrl}/products/$id.json?auth=$authToken';
    final res = await http.delete(url);
    if (res.statusCode >= 400) {
      // rollback if fails
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('delete failed');
    }
  }
}
