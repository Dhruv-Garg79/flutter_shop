import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_zone/providers/product.dart';
import 'package:shop_zone/providers/products.dart';
import 'package:shop_zone/screens/edit_product_screen.dart';
import 'package:shop_zone/widgets/main_drawer.dart';

class UserProductScreen extends StatelessWidget {
  static const routeName = '/userProductScreen';

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<Products>(context).items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          )
        ],
      ),
      drawer: MainDrawer(),
      body: Container(
        margin: EdgeInsets.all(16.0),
        child: ListView.builder(
          itemBuilder: (ctx, i) {
            return UserProductItem(productData[i]);
          },
          itemCount: productData.length,
        ),
      ),
    );
  }
}

class UserProductItem extends StatelessWidget {
  final Product product;
  UserProductItem(this.product);

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<Products>(context, listen: false);

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(product.imageUrl),
        ),
        title: Text(product.title),
        trailing: Container(
          width: 100,
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  Navigator.of(context).pushNamed(EditProductScreen.routeName, arguments: product);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                color: Theme.of(context).errorColor,
                onPressed: () => productProvider.removeProduct(product.id),
              )
            ],
          ),
        ),
      ),
    );
  }
}
