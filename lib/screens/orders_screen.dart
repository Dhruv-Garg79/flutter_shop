import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shop_zone/widgets/main_drawer.dart';
import '../providers/orders.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/ordersScreen';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _isInit = true;
  bool _loading = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      Provider.of<Orders>(context, listen: false).fetchOrders().then((_) {
        setState(() {
          _loading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<Orders>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: MainDrawer(),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () async {
                setState(() => _loading = true);
                await orderProvider.fetchOrders();
                setState(() => _loading = false);
              },
              child: ListView.builder(
                itemBuilder: (ctx, i) =>
                    OrderItemWidget(orderProvider.orders[i]),
                itemCount: orderProvider.orders.length,
              ),
            ),
    );
  }
}

class OrderItemWidget extends StatefulWidget {
  final OrderItem orderItem;
  const OrderItemWidget(
    this.orderItem, {
    Key key,
  }) : super(key: key);

  @override
  _OrderItemWidgetState createState() => _OrderItemWidgetState();
}

class _OrderItemWidgetState extends State<OrderItemWidget> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text('\$${widget.orderItem.amount}'),
            subtitle: Text(DateFormat.yMEd().format(widget.orderItem.dateTime)),
            trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
            ),
          ),
          if (_expanded)
            Container(
              margin: EdgeInsets.all(16.0),
              padding: EdgeInsets.all(8.0),
              height: min(widget.orderItem.items.length * 30.0, 150),
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorDark.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8.0)),
              child: ListView.builder(
                itemBuilder: (ctx, i) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(widget.orderItem.items[i].title),
                      Text(
                        '${widget.orderItem.items[i].quantity}x${widget.orderItem.items[i].price}',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  );
                },
                itemCount: widget.orderItem.items.length,
              ),
            ),
        ],
      ),
    );
  }
}
