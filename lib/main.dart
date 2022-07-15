import 'package:flutter/material.dart';
import 'package:my_shop/screens/products_overview_screen.dart';
import 'package:my_shop/screens/splash_screen.dart';
import 'package:provider/provider.dart';

import './models/auth.dart';
import './screens/auth_screen.dart';
import './models/cart.dart';
import './screens/cart_screen.dart';
import './models/product_api.dart';
import './models/orders_api.dart';

// If we don't use the context, it makes sense to use .vlaue instaed of create
// When working with provider around item in list or grid, we should use the
// .value approach.
// Here, as we instanciate a new object of class products, we should use the create
// approach. On the other hand, in products_grid, when wrapping existing product item
// with ChangeNotifierProvider, we should use the value approach.
// ChangeNotifierProvider.value(
// value: Products(),

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => Auth()),
      ChangeNotifierProvider(create: (_) => ProductApi()),
      // ChangeNotifierProxyProvider<Auth, ProductApi>(
      //     create: (context) => ProductApi(),
      //     update: (context, auth, prevProductApi) => ProductApi(
      //         authToken: auth.token,
      //         products: prevProductApi == null ? [] : prevProductApi.items)),
      ChangeNotifierProvider(create: (_) => Cart()),
      ChangeNotifierProvider(create: (_) => OrdersApi())
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Auth>(
        builder: (context, auth, child) => MaterialApp(
              title: 'MyShop',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                  // primarySwatch: Colors.purple,
                  colorScheme: ColorScheme.fromSwatch(
                    primarySwatch: Colors.purple,
                    accentColor: Colors.deepOrange,
                  ),
                  fontFamily: 'Lato'),
              // home: auth.isAuth ? ProductsOverviewScreen() : AuthScreen(),
              home: auth.isAuth
                  ? ProductsOverviewScreen()
                  : FutureBuilder(
                      future: auth.tryAutoLogin(),
                      builder: (ctx, snapshot) =>
                          snapshot.connectionState == ConnectionState.waiting
                              ? SplashScreen()
                              : AuthScreen()),
              routes: {
                CartScreen.routeName: (_) => CartScreen(),
              },
            ));
  }
}
