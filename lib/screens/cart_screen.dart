import 'package:flutter/material.dart';
import 'package:my_shop/models/order.dart';
import 'package:my_shop/models/orders_api.dart';
import 'package:my_shop/widgets/cart_item_widget.dart';
import 'package:provider/provider.dart';

import '../models/cart.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart-screen';
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(
                      '\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  // we decided to move the button code to separate widget "OrderNowButton"
                  // and kept it in this same file.
                  OrderNowButton(cart: cart)
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
              child: ListView.builder(
                  // could use also the getter cart.itemCount
                  itemCount: cart.items.length,
                  itemBuilder: (ctx, index) => CartItemWidget(
                      cart.items.values.toList()[index],
                      cart.items.keys.toList()[index])))
        ],
      ),
    );
  }
}

class OrderNowButton extends StatefulWidget {
  const OrderNowButton({
    Key? key,
    required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  State<OrderNowButton> createState() => _OrderNowButtonState();
}

class _OrderNowButtonState extends State<OrderNowButton> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: SizedBox(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : const Text('Order Now'),
        width: 120,
      ),
      onPressed: widget.cart.totalAmount <= 0 || _isLoading
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              await Provider.of<OrdersApi>(context, listen: false).addOrder(
                  Order(
                      id: DateTime.now().toString(),
                      totalAmount: widget.cart.totalAmount,
                      lines: widget.cart.items.values.toList(),
                      dateTime: DateTime.now()));
              setState(() {
                _isLoading = false;
              });
              widget.cart.clear();
            },
    );
  }
}
