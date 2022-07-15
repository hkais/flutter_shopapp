import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_api.dart';

class ProductDetailsScreen extends StatelessWidget {
  final String productId;

  // Here we pass the productId through the ctor instead of whole product object.
  // We fetch the product object from the list of products supplied by provider.
  ProductDetailsScreen(this.productId);
  @override
  Widget build(BuildContext context) {
    // final product = Provider.of<Products>(
    //   context,
    //   listen: false,
    // ).items.firstWhere((item) => item.id == productId);

    // we moved finding the product object code to Products class from provider
    final product =
        Provider.of<ProductApi>(context, listen: false).findById(productId);
    return Scaffold(
        appBar: AppBar(
          title: Text(product.title),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 300,
                width: double.infinity,
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '\$${product.price}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              Text(product.description, softWrap: true,textAlign: TextAlign.center,)
            ],
          ),
        ));
  }
}
