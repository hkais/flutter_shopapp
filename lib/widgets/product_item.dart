import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart.dart';
import '../screens/product_details_screen.dart';
import '../models/product.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Consumer vs Provider Of Context
    // In the provider of context approach the whole build method will
    // re run after the data changes.
    // Here we mixed both; we used the provide of approach to get the product
    // when the widget builds without listening to changes, while we wrapped
    // the favorate icon area with consumer to update it whenever the isFvaorate
    // flag of the product changes...
    final product = Provider.of<Product>(context);
    final cart = Provider.of<Cart>(context, listen: false);
    // print('${product.id} product item rebuilds...............................');
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProductDetailsScreen(product.id)));
        },
        child: GridTile(
          child: product.imageUrl.isEmpty ? Container() : Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
          footer: GridTileBar(
            backgroundColor: Colors.black87,
            leading: Consumer<Product>(
              builder: (ctx, product, child) => IconButton(
                onPressed: () {
                  product.toggleFavorateStatus();
                },
                icon: Icon(product.isFavorate
                    ? Icons.favorite
                    : Icons.favorite_border),
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            title: Text(
              product.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10),
            ),
            trailing: IconButton(
              onPressed: () {
                cart.addItem(product.id, product.title, product.price);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text(
                    "Item Added To Cart!",
                  ),
                  duration: const Duration(seconds: 2),
                  action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        cart.undoAddToCart(product.id);
                      }),
                ));
              },
              icon: const Icon(Icons.shopping_cart),
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
      ),
    );
  }
}
