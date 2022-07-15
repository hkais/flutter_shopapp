import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import '../models/order.dart';

class OrderInListWidget extends StatefulWidget {
  final Order order;
  OrderInListWidget(this.order);

  @override
  State<OrderInListWidget> createState() => _OrderInListWidgetState();
}

class _OrderInListWidgetState extends State<OrderInListWidget> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title:
                Text('Total: \$${widget.order.totalAmount.toStringAsFixed(2)}'),
            subtitle: Text(
              DateFormat('dd/MM/yyyy  HH:mm').format(widget.order.dateTime),
              style: TextStyle(fontSize: 12),
            ),
            trailing: IconButton(
                onPressed: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more)),
          ),
          if (isExpanded)
            Container(
              color: Colors.yellow[100],
              padding: const EdgeInsets.all(10),
              height:  min(widget.order.lines.length * 40 + 40, 200),
              child: ListView(
                children: widget.order.lines
                    .map((line) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(line.title),
                              Text('${line.quantity}x \$${line.price}')
                            ],
                          ),
                    ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
