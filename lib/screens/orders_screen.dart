import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../widgets/order_in_list_widget.dart';
import '../models/orders_api.dart';

class OrdersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // final ordersApi = Provider.of<OrdersApi>(context);

    // Here we tried to implement the FutureBuilder widget.
    // 1. no need for fetching in initState
    // 2. we fetch the data inside FutureBuilder, property future!
    // 3. we omit the listening object ordersApi on top of build method
    //    and replace it with consumer around the part of the real data
    //    in the future builder, in our case its the listview...

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      body: FutureBuilder(
        future: Provider.of<OrdersApi>(context, listen: false).fetchOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.error != null) {
              return Center(
                  child: Text('An error occured!${snapshot.error.toString()}'));
            } else {
              return Consumer<OrdersApi>(
                  builder: (context, orderapi, child) => ListView.builder(
                        itemCount: orderapi.orders.length,
                        itemBuilder: (ctx, index) {
                          return OrderInListWidget(orderapi.orders[index]);
                        },
                      ));
            }
          }
        },
      ),
      drawer: AppDrawer(),
    );
  }
}
