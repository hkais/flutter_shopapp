import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_api.dart';
import '../widgets/app_drawer.dart';
import '../widgets/products_grid.dart';
import '../models/cart.dart';
import '../widgets/badge.dart';
import '../screens/cart_screen.dart';

enum FilterOptions { favorates, all }

class ProductsOverviewScreen extends StatefulWidget {
  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  bool _showFavoratesOnly = false;
  bool _initDone = false;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    if (!_initDone) {
      setState(() {
        _isLoading = true;
      });

      Provider.of<ProductApi>(context).fetchProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
        _initDone = true;
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // final productsApi = Provider.of<Products>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shop'),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.favorates) {
                  _showFavoratesOnly = true;
                } else {
                  _showFavoratesOnly = false;
                }
              });
            },
            icon: const Icon(Icons.more_vert),
            itemBuilder: (ctx) {
              return [
                const PopupMenuItem(
                  child: Text('Favorates'),
                  value: FilterOptions.favorates,
                ),
                const PopupMenuItem(
                    child: Text('All'), value: FilterOptions.all),
              ];
            },
          ),
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              child: ch!,
              value: cart.itemCount.toString(),
            ),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
              icon: const Icon(Icons.shopping_cart),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ProductsGrid(_showFavoratesOnly),
      drawer: AppDrawer(),
    );
  }
}
