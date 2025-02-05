import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  // List of cart items with their details (ID, name, expDate, price)
  List<CartItem> _cartItems = [
    CartItem(id: 1, name: "Paracetamol", expDate: "2025-5-2", price: 5),
    CartItem(id: 2, name: "Aspirin", expDate: "2025-4-2", price: 10),
    CartItem(id: 3, name: "Ibuprofen", expDate: "2025-8-27", price: 15),

  ];

  List<CartItem> get cartItems => _cartItems;

  // Total Price Calculation
  int get totalPrice {
    return _cartItems.fold(0, (prev, item) => prev + item.price);
  }

  // Function to add an item to the cart
  void addItem(CartItem item) {
    _cartItems.add(item);
    notifyListeners();
  }

  // Function to remove an item from the cart by index
  void removeItem(int index) {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems.removeAt(index);
      notifyListeners();
    }
  }

  // Function to clear the cart
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}

class CartItem {
  final int id;
  final String name;
  final String expDate;
  final int price;

  CartItem({
    required this.id,
    required this.name,
    required this.expDate,
    required this.price,
  });
}
