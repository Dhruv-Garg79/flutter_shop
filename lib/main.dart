import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_zone/helper/custom_route.dart';
import 'package:shop_zone/providers/auth.dart';
import 'package:shop_zone/providers/cart.dart';
import 'package:shop_zone/providers/orders.dart';
import 'package:shop_zone/providers/products.dart';
import 'package:shop_zone/screens/auth_screen.dart';
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
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (ctx) => Products("", [], ""),
          update: (ctx, auth, prevProducts) =>
              Products(auth.token, prevProducts.items, auth.userID),
        ),
        ChangeNotifierProvider.value(
          value: Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (ctx) => Orders("", "", []),
          update: (ctx, auth, prevOrders) =>
              Orders(auth.token, auth.userID, prevOrders.orders),
        )
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'SHOP ZONE',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.red,
            fontFamily: 'lato',
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                TargetPlatform.android : CustomPageTransitionBuilder(),
                TargetPlatform.iOS : CustomPageTransitionBuilder(),
              },
            ),
          ),
          home: auth.isAuthenticated
              ? ProductOverviewScreen()
              : FutureBuilder(
                  future: auth.autoLogin(),
                  builder: (ctx, dataSnap) =>
                      dataSnap.connectionState == ConnectionState.waiting
                          ? Scaffold(
                              body: Center(
                                child: Text('Loading...'),
                              ),
                            )
                          : AuthScreen(),
                ),
          routes: {
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            ProductOverviewScreen.routeName: (ctx) => ProductOverviewScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductScreen.routeName: (ctx) => UserProductScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
            AuthScreen.routeName: (ctx) => AuthScreen(),
          },
        ),
      ),
    );
  }
}
