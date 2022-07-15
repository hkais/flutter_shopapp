// ignore_for_file: prefer_const_constructors_in_immutables, avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../models/product_api.dart';

class ProductEditScreen extends StatefulWidget {
  final Product product;

  // ignore: use_key_in_widget_constructors
  ProductEditScreen(this.product);

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  Product _editedProduct = Product.empty();
  var _initDone = false;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (!_initDone) {
      if (widget.product.id.isNotEmpty) {
        _editedProduct = Product.copyFrom(widget.product);
        _initDone = true;
      }
      _imageUrlController.text = _editedProduct.imageUrl;
    }

    super.didChangeDependencies();
  }

  Future<void> _saveForm() async {
    bool isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    if (_editedProduct.imageUrl.isEmpty) {
      _editedProduct.imageUrl = "https://picsum.photos/200/300";
    }

    if (_editedProduct.id.isEmpty) {
      _editedProduct.id = DateTime.now().toIso8601String();

      try {
        await Provider.of<ProductApi>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: const Text('Error Adding Product'),
                content: Text('Details: $error'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Got It!'))
                ],
              );
            });
      }
      // finally {
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }
    } else {
      try {
        await Provider.of<ProductApi>(context, listen: false)
            .updateProduct(widget.product.id, _editedProduct);
      } catch (error) {
        await showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: const Text('Error Updating Product'),
                content: Text('Details: $error'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Got It!'))
                ],
              );
            });
      }
      // finally {
      //   setState(() {
      //     _isLoading = false;
      //     Navigator.of(context).pop();
      //   });
      // }
    }

    setState(() {
      _isLoading = false;
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Product'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () => _saveForm(),
            )
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(12.0),
                child: Form(
                    key: _form,
                    // autovalidateMode: AutovalidateMode.always,
                    child: ListView(
                      children: [
                        TextFormField(
                          initialValue: _editedProduct.title,
                          decoration: const InputDecoration(labelText: 'Title'),
                          textInputAction: TextInputAction.next,
                          onSaved: (value) =>
                              _editedProduct.title = value ?? '',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter the product title!';
                            }
                            if (value.trim().length < 4) {
                              return 'Title must be at least 4 chars!';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          initialValue: _editedProduct.price != 0
                              ? _editedProduct.price.toStringAsFixed(2)
                              : '',
                          decoration: const InputDecoration(labelText: 'Price'),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          onSaved: (value) => _editedProduct.price =
                              value != null && value.isNotEmpty
                                  ? double.parse(value)
                                  : 0.0,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a price!';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid price!';
                            }
                            if (double.parse(value) <= 0) {
                              return 'Price should be graeter than zero!';
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          initialValue: _editedProduct.description,
                          decoration:
                              const InputDecoration(labelText: 'Description'),
                          maxLines: 3,
                          keyboardType: TextInputType.multiline,
                          onSaved: (value) =>
                              _editedProduct.description = value ?? '',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter the product description!';
                            }
                            if (value.trim().length < 2) {
                              return 'Description must be at least 15 chars!';
                            }
                            return null;
                          },
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              margin: const EdgeInsets.only(right: 10, top: 8),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.grey),
                              ),
                              child: _imageUrlController.text.isEmpty
                                  ? const Center(child: Text('X'))
                                  : FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Image.network(
                                          _imageUrlController.text.trim())),
                            ),
                            Expanded(
                              child: TextFormField(
                                // initialValue: _editedProduct.imageUrl,
                                decoration: const InputDecoration(
                                    labelText: 'Image Url'),
                                keyboardType: TextInputType.url,
                                textInputAction: TextInputAction.done,
                                controller: _imageUrlController,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )),
              ));
  }
}
