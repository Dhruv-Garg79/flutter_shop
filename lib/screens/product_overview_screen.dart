import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_zone/providers/cart.dart';
import 'package:shop_zone/providers/products.dart';
import 'package:shop_zone/screens/cart_screen.dart';
import 'package:shop_zone/widgets/badge.dart';
import 'package:shop_zone/widgets/main_drawer.dart';
import 'package:shop_zone/widgets/product_item.dart';

enum FilterOptions { Fav, All }

class ProductOverviewScreen extends StatefulWidget {
  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  bool _showOnlyFavs = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Shop'),
        actions: <Widget>[
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Favorites'),
                value: FilterOptions.Fav,
              ),
              PopupMenuItem(
                child: Text('All'),
                value: FilterOptions.All,
              ),
            ],
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                _showOnlyFavs = selectedValue == FilterOptions.Fav;
              });
            },
          ),
          Consumer<Cart>(
            builder: (_, cartData, ch) => Badge(
              child: ch,
              value: cartData.itemCount.toString(),
            ),
            child: IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () => Navigator.of(context).pushNamed(CartScreen.routeName),
              )
          ),
        ],
      ),
      drawer: MainDrawer(),
      body: ProductsGrid(_showOnlyFavs),
    );
  }
}

class ProductsGrid extends StatelessWidget {
  final _showOnlyFavs;

  ProductsGrid(this._showOnlyFavs);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<Products>(context);
    final products = _showOnlyFavs ? provider.favItems : provider.items;

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemBuilder: (ctx, i) {
        //ChangeNotifierProvider.value should be used with lists because it takes care of recycled items and it's data
        return ChangeNotifierProvider.value(
          value: products[i],
          child: ProductItem(),
        );
      },
    );
  }
}
