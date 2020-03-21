import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_zone/providers/auth.dart';
import 'package:shop_zone/providers/cart.dart';
import 'package:shop_zone/providers/product.dart';
import 'package:shop_zone/screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final auth = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                arguments: product.id);
          },
          child: Hero(
            tag: product.id,
            child: FadeInImage(
              placeholder: AssetImage('assets/images/placeholder.png'),
              image: NetworkImage(product.imageUrl),
              fit: BoxFit.cover,
            ),
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
                onPressed: () async {
                  try {
                    await pro.toggleFav(auth.token, auth.userID);
                  } catch (error) {
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text('Something went wrong! Favorite failed'),
                    ));
                  }
                },
              );
            },
          ),
          trailing: IconButton(
              icon: Icon(Icons.shopping_cart),
              color: Theme.of(context).primaryColorLight,
              onPressed: () {
                cart.addItem(
                  product.id,
                  product.title,
                  product.description,
                  product.price,
                  product.imageUrl,
                );
                Scaffold.of(context).hideCurrentSnackBar();
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text(
                    'Added Item to cart!',
                  ),
                  duration: Duration(seconds: 2),
                  action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () {
                        cart.removeSingleItem(product.id);
                      }),
                ));
              }),
        ),
      ),
    );
  }
}
