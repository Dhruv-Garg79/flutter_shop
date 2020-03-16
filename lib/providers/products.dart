import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shop_zone/constants.dart';
import 'package:shop_zone/models/http_exception.dart';
import 'package:shop_zone/providers/product.dart';

class Products with ChangeNotifier {

  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  List<Product> get favItems {
    return _items.where((pro) => pro.isFavorite).toList();
  }

  List<Product> get items {
    return [..._items];
  }

  Product getProductById(String id) {
    return _items.firstWhere((pro) => pro.id == id);
  }

  Future<void> fetchProducts() async {
    const url = '${Constants.baseUrl}/products.json';

    try {
      final response = await http.get(url);
      final data = json.decode(response.body) as Map<String, dynamic>;

      List<Product> loadedItems = [];
      data.forEach((key, map) {
        loadedItems.add(Product(
          id: key,
          title: map['title'],
          description: map['description'],
          price: map['price'],
          imageUrl: map['imageUrl'],
          isFavorite: map['isFavorite'],
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
    const url = '${Constants.baseUrl}/products.json';

    try {
      final response = await http.post(url, body: product.toJson());

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

    final url = '${Constants.baseUrl}/products/$id.json';
    final res = await http.delete(url);
    if (res.statusCode >= 400) {
      // rollback if fails
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('delete failed');
    }
  }
}
