// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/product.dart';
import '../constants/back_end_contsants.dart' as consts;
import './product.dart';
import './http_exception.dart';

class ProductApi with ChangeNotifier {
  List<Product> _items = [];
  final url = consts.baseUrl + 'products';

  String? token;

  Future<void> fetchProducts() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    final uri = Uri.parse('$url${consts.queryTail}?auth=$token');
    try {
      final response = await http.get(uri);
      _items = (json.decode(response.body) as Map<String, dynamic>)
          .values
          .map((p) => Product.fromJson(p))
          .toList();
      notifyListeners();
    } catch (error) {
      // rethrow;
    }
  }

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favorateItems {
    return _items.where((item) => item.isFavorate == true).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> addProduct(Product product) async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    var uri = Uri.parse('$url/${consts.queryTail}?auth=$token');
    try {
      final response = await http.post(uri, body: product.toJson());
      product.id = json.decode(response.body)['name'].toString();
      uri = Uri.parse('$url/${product.id}${consts.queryTail}?auth=$token');
      await http.put(uri, body: product.toJson());
      _items.add(product);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateProduct(String productId, Product newProduct) async {
    final index = _items.indexWhere((prod) => prod.id == productId);

    if (index < 0) return;

    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');

    final uri = Uri.parse('$url/$productId${consts.queryTail}?auth=$token');
    await http.patch(uri, body: newProduct.toJson());
    _items[index] = newProduct;
    notifyListeners();
  }

  Future<void> deleteProduct(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    
    final uri = Uri.parse('$url/$productId${consts.queryTail}?auth=$token');
    //// Optimostic update
    final productIndex = _items.indexWhere((prod) => prod.id == productId);
    if (productIndex < 0) return;

    //// kept in memeory for rolling back
    Product? product = _items[productIndex];
    _items.removeAt(productIndex);
    notifyListeners();
    final response = await http.delete(uri);
    if (response.statusCode >= 400) {
      _items.insert(productIndex, product);
      notifyListeners();
      throw HttpException('Could not delete product at server!');
    }
    product = null;
  }
}
