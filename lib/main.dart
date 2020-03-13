import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_zone/providers/products.dart';
import 'package:shop_zone/screens/product_detail_screen.dart';
import 'package:shop_zone/screens/product_overview_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => Products(),
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
        },
      ),
    );
  }
}