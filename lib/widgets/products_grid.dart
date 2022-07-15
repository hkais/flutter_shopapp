import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_api.dart';
import '../widgets/product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavoratesOnly;

  ProductsGrid(this.showFavoratesOnly);

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductApi>(context);
    final products = showFavoratesOnly ? productsData.favorateItems : productsData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10),
      itemBuilder: (context, index) => ChangeNotifierProvider.value(
        // create: (_) => products[index],
        value: products[index],
        child: ProductItem()),
    );
  }
}