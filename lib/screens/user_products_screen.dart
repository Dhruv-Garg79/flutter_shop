import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_zone/providers/product.dart';
import 'package:shop_zone/providers/products.dart';
import 'package:shop_zone/screens/edit_product_screen.dart';
import 'package:shop_zone/widgets/main_drawer.dart';

class UserProductScreen extends StatelessWidget {
  static const routeName = '/userProductScreen';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    print('rebuilding...........');
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
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, snapShot) => snapShot.connectionState ==
                ConnectionState.waiting
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => _refreshProducts(context),
                child: Consumer<Products>(
                  builder: (ctx, productData, _) => Container(
                    margin: EdgeInsets.all(16.0),
                    child: productData.items.length > 0
                        ? ListView.builder(
                            itemBuilder: (ctx, i) {
                              return UserProductItem(productData.items[i]);
                            },
                            itemCount: productData.items.length,
                          )
                        : Center(
                            child: Text('You haven\'t created any product')),
                  ),
                ),
              ),
      ),
    );
  }
}

class UserProductItem extends StatelessWidget {
  final Product product;
  UserProductItem(this.product);

  Future<void> _deleteProduct(
      ScaffoldState scaffold, Products productProvider) async {
    try {
      await productProvider.removeProduct(product.id);
    } catch (err) {
      scaffold.showSnackBar(
        SnackBar(
          content: Text(err.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<Products>(context, listen: false);
    final scaffold = Scaffold.of(context);
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
                  Navigator.of(context).pushNamed(EditProductScreen.routeName,
                      arguments: product);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                color: Theme.of(context).errorColor,
                onPressed: () => _deleteProduct(scaffold, productProvider),
              )
            ],
          ),
        ),
      ),
    );
  }
}
