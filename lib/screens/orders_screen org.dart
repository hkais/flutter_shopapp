import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../widgets/order_in_list_widget.dart';
import '../models/orders_api.dart';

class OrdersScreenOrg extends StatefulWidget {
  @override
  State<OrdersScreenOrg> createState() => _OrdersScreenOrgState();
}

class _OrdersScreenOrgState extends State<OrdersScreenOrg> {
  bool _isLoading = false;

  @override
  void initState() {
    // A diiferent approach for fetching the data
    Future.delayed(Duration.zero).then((_) async {
      setState(
        () {
          _isLoading = true;
        },
      );
      await Provider.of<OrdersApi>(context, listen: false).fetchOrders();
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ordersApi = Provider.of<OrdersApi>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: ordersApi.orders.length,
              itemBuilder: (ctx, index) {
                return OrderInListWidget(ordersApi.orders[index]);
              },
            ),
      drawer: AppDrawer(),
    );
  }
}
