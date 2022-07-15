import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/order.dart';
import '../constants/back_end_contsants.dart' as consts;

class OrdersApi with ChangeNotifier {
  final url = consts.baseUrl + 'orders';
  List<Order> _orders = [];

  List<Order> get orders {
    return [..._orders];
  }

  String? token;
  Future<void> fetchOrders() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');

    final uri = Uri.parse('$url${consts.queryTail}?auth=$token');
    try {
      final response = await http.get(uri);
      _orders = (json.decode(response.body) as Map<String, dynamic>)
          .values
          .map((o) => Order.fromJson(o))
          .toList();
      _orders.sort((o1, o2) => -1 * o1.dateTime.compareTo(o2.dateTime));
      // or _orders.revesred.toList()
      notifyListeners();
    } catch (error) {
      // print('error:.......... ' + error.toString());
    }
  }

  Future<void> addOrder(Order order) async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    var uri = Uri.parse('$url${consts.queryTail}?auth=$token');
    try {
      final response = await http.post(uri, body: order.toJson());
      // we want to "put" again to save the order with id
      // equals to docid given by firebase.
      order.id = json.decode(response.body)['name'].toString();
      uri = Uri.parse('$url/${order.id}${consts.queryTail}?auth=$token');
      await http.put(uri, body: order.toJson());
      _orders.insert(0, order);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
    // Error handling in details appear in addProduct method.
  }
}
