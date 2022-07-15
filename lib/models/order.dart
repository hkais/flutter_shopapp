import 'dart:convert';
import '../models/cart.dart';

class Order {
  String id;
  double totalAmount;
  List<CartItem> lines;
  DateTime dateTime;

  Order({
    required this.id,
    required this.totalAmount,
    required this.lines,
    required this.dateTime,
  });

  Order.empty()
      : id = '',
        totalAmount = 0,
        lines = [],
        dateTime = DateTime.now();

  Order.fromJson(dynamic source)
      : id = source['id'] ?? '',
        totalAmount = source['totalAmount'] ?? 0.0,
        lines = source['lines'].map<CartItem>(CartItem.fromJson).toList()  ?? [],
        dateTime = DateTime.tryParse(source['dateTime']) ?? DateTime.now();

  Order.copyFrom(Order order)
      : id = order.id,
        totalAmount = order.totalAmount,
        lines = order.lines,
        dateTime = order.dateTime;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'totalAmount': totalAmount,
      'lines': lines.map((line) => line.toMap()).toList(),
      'dateTime': dateTime.toIso8601String()
    };
  }

  toJson() {
    return json.encode(toMap());
  }
}
