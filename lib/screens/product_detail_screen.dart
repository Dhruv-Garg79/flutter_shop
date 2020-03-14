import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_zone/providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/productDetail';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments as String;
    final product =
        Provider.of<Products>(context, listen: false).getProductById(productId);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 400,
              width: double.infinity,
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
              ),
              margin: EdgeInsets.only(bottom: 16.0),
            ),
            Container(
              margin: EdgeInsets.only(left: 8.0),
              child: Text(
                product.title,
                style: TextStyle(fontSize: 24.0),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 8.0),
              child: Text(
                product.description,
                maxLines: 2,
                style: TextStyle(fontSize: 20.0),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 8.0),
              child: Text(
                '\$${product.price}',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
