import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_zone/providers/cart.dart';
import 'package:shop_zone/providers/product.dart';
import 'package:shop_zone/screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                arguments: product.id);
          },
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Theme.of(context).primaryColorDark.withOpacity(0.75),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          leading: Consumer<Product>(
            builder: (ctx, pro, child) {
              return IconButton(
                icon: Icon(Icons.favorite),
                color: pro.isFavorite
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).primaryColorLight,
                onPressed: () => pro.toggleFav(),
              );
            },
          ),
          trailing: IconButton(
            icon: Icon(Icons.shopping_cart),
            color: Theme.of(context).primaryColorLight,
            onPressed: () => cart.addItem(product.id, product.title, product.description, product.price, product.imageUrl),
          ),
        ),
      ),
    );
  }
}
