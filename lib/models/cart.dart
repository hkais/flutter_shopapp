import 'package:flutter/material.dart';
import 'dart:convert';

class CartItem {
  String id;
  String title;
  int quantity;
  double price;

  CartItem({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
  });


  CartItem.fromJson(dynamic source)
      : id = source['id'] ?? '',
        title = source['title'] ?? '',
        quantity = source['quantity']??  0,
        price = source['price'] ??0.0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'quantity': quantity,
      'price': price,
    };
  }

  toJson() {
    return json.encode(toMap());
  }


}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    double total = 0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(String productId, String title, double price) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (cartItem) => CartItem(
          id: cartItem.id,
          title: cartItem.title,
          quantity: cartItem.quantity + 1,
          price: cartItem.price,
        ),
      );
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: DateTime.now().toString(),
          title: title,
          quantity: 1,
          price: price,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void undoAddToCart(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId]!.quantity > 1) {
      _items[productId]!.quantity = _items[productId]!.quantity - 1;
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
