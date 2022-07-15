import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_api.dart';
import '../screens/product_edit_screen.dart';
import '../models/product.dart';

class StoreProductInList extends StatelessWidget {
  final Product product;

  StoreProductInList(this.product);
  @override
  Widget build(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    return ListTile(
      leading: product.imageUrl.isNotEmpty
          ? CircleAvatar(
              backgroundImage: NetworkImage(product.imageUrl),
            )
          : const CircleAvatar(
              backgroundColor: Colors.pink,
              child: Text('M'),
            ),
      title: Text(product.title),
      trailing: SizedBox(
        width: 100,
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.edit,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ProductEditScreen(product)));
              },
            ),
            IconButton(
              icon: Icon(
                Icons.delete,
                color: Theme.of(context).errorColor,
              ),
              onPressed: () async {
                bool confirm = await showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Are you sure?'),
                    content: const Text('Remove the product from the store?!'),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: const Text('Yes')),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: const Text('No'))
                    ],
                  ),
                );
                if (confirm) {
                  try {
                    await Provider.of<ProductApi>(context, listen: false)
                        .deleteProduct(product.id);
                  } catch (error) {
                      scaffoldMessenger.showSnackBar(SnackBar(content: Text(error.toString())));
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
