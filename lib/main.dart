import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_zone/providers/cart.dart';
import 'package:shop_zone/providers/orders.dart';
import 'package:shop_zone/providers/products.dart';
import 'package:shop_zone/screens/cart_screen.dart';
import 'package:shop_zone/screens/edit_product_screen.dart';
import 'package:shop_zone/screens/orders_screen.dart';
import 'package:shop_zone/screens/product_detail_screen.dart';
import 'package:shop_zone/screens/product_overview_screen.dart';
import 'package:shop_zone/screens/user_products_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Products(),
        ),
        ChangeNotifierProvider.value(
          value: Cart(),
        ),
        ChangeNotifierProvider.value(
          value: Orders(),
        )
      ],
      child: MaterialApp(
        title: 'SHOP ZONE',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.red,
            fontFamily: 'lato'),
        home: ProductOverviewScreen(),
        routes: {
          ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
          CartScreen.routeName: (ctx) => CartScreen(),
          OrdersScreen.routeName: (ctx) => OrdersScreen(),
          UserProductScreen.routeName: (ctx) => UserProductScreen(),
          EditProductScreen.routeName: (ctx) => EditProductScreen(),
        },
      ),
    );
  }
}
