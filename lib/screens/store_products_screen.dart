import 'package:flutter/material.dart';
import 'package:my_shop/models/product.dart';
import 'package:provider/provider.dart';

import '../models/product_api.dart';
import '../widgets/app_drawer.dart';
import '../widgets/store_product_in_list.dart';
import '../screens/product_edit_screen.dart';

class StoreProductsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final products = Provider.of<ProductApi>(context).items;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ProductEditScreen(Product.empty())));
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            Provider.of<ProductApi>(context, listen: false).fetchProducts(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (ctx, index) => Column(
                    children: [StoreProductInList(products[index]), Divider()],
                  )),
        ),
      ),
      drawer: AppDrawer(),
    );
  }
}
