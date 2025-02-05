import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Cart.dart';

class SellPage extends StatelessWidget {
  const SellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(horizontal: 8),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bill",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      "Placeholder pharmacy name",
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    const Divider(),

                    // List of medicines and prices
                    Column(
                      children: List.generate(cartProvider.cartItems.length, (index) {
                        final item = cartProvider.cartItems[index];
                        return ListTile(
                          title: Text(item.name),
                          subtitle: Text("Price: \$${item.price}"),
                          onTap: () {
                            cartProvider.removeItem(index); // Remove item on tap
                          },
                        );
                      }),
                    ),

                    const Divider(),
                    const SizedBox(height: 10),

                    // Total Price Calculation
                    Text(
                      "Total Price: \$${cartProvider.totalPrice}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            cartProvider.clearCart(); // Clear cart on cancel
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: Text(
                            'Cancel',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Handle sell action
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: Text(
                            'Sell',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

