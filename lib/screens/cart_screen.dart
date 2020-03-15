import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_zone/providers/cart.dart';
import 'package:shop_zone/providers/orders.dart';

class CartScreen extends StatelessWidget {
  static const routeName = 'cartScreen';

  @override
  Widget build(BuildContext context) {
    final cartprovider = Provider.of<Cart>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(16.0),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Your Total : ',
                        style: TextStyle(fontSize: 18),
                      ),
                      Chip(
                        label: Text(
                          cartprovider.totalAmount.toString(),
                        ),
                      ),
                    ],
                  ),
                  RaisedButton(
                    child: Text('Order Now'),
                    onPressed: () {
                      Provider.of<Orders>(context, listen: false).addOrder(
                          cartprovider.itemValues, cartprovider.totalAmount);
                      cartprovider.clear();
                    },
                    color: Theme.of(context).primaryColorLight,
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (_, i) {
                return buildCartItem(context, cartprovider.itemKeys[i],
                    cartprovider.itemValues[i]);
              },
              itemCount: cartprovider.itemCount,
            ),
          )
        ],
      ),
    );
  }

  Widget buildCartItem(
      BuildContext context, String productId, CartItem cartItem) {
    final provider = Provider.of<Cart>(context);
    return Dismissible(
      key: ValueKey(cartItem.id),
      background: Container(
        color: Theme.of(context).errorColor,
        child: Icon(Icons.delete),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 16),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (dir) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Are you sure?'),
            content: Text('Do you want to remove this item from cart?'),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text('Yes'),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text('No'),
              ),
            ],
          ),
        );
      },
      onDismissed: (dir) {
        provider.removeItem(productId);
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: Image.network(
                  cartItem.imageUrl,
                  fit: BoxFit.cover,
                  width: 100,
                  height: 100,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      cartItem.title,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Text(
                        cartItem.desc,
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '\$${cartItem.price}',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 8.0),
                      child: Row(children: <Widget>[
                        IconButton(
                          onPressed: () =>
                              provider.decrementQuantityFor(productId),
                          icon: Icon(Icons.remove),
                        ),
                        Text(cartItem.quantity.toString()),
                        IconButton(
                          onPressed: () =>
                              provider.incrementQuantityFor(productId),
                          icon: Icon(Icons.add),
                        ),
                      ]),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
