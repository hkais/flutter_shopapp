import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/back_end_contsants.dart' as consts;

class Product with ChangeNotifier {
  String id;
  String title;
  String description;
  double price;
  String imageUrl;
  bool isFavorate;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorate = false,
  });

  Product.empty()
      : id = '',
        title = '',
        description = '',
        price = 0.0,
        imageUrl = '',
        isFavorate = false;

  Product.fromJson(dynamic source)
      : id = source['id'] ?? '',
        title = source['title'] ?? '',
        description = source['description'] ?? '',
        price = source['price'] ?? 0,
        imageUrl = source['imageUrl'] ?? '',
        isFavorate = source['isFavorate'] ?? false;

  Product.copyFrom(Product product)
      : id = product.id,
        title = product.title,
        description = product.description,
        price = product.price,
        imageUrl = product.imageUrl,
        isFavorate = product.isFavorate;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'isFavorate': isFavorate
    };
  }

  String toJson() {
    return json.encode(toMap());
  }

  Future<void> toggleFavorateStatus() async {
    final url = consts.baseUrl + 'products';
    final oldStatus = isFavorate;
    isFavorate = !isFavorate;
    notifyListeners();
    String? token;
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    final uri = Uri.parse('$url/$id${consts.queryTail}?auth=$token');

    try {
      final response =
          await http.patch(uri, body: json.encode({'isFavorate': isFavorate}));

      if (response.statusCode >= 400) {
        isFavorate = oldStatus;
      }
    } catch (e) {
      isFavorate = oldStatus;
    }
    notifyListeners();
  }
}
