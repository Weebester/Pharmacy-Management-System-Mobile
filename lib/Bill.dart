import 'package:flutter/material.dart';

class BillState with ChangeNotifier {
  // List of cart items with their details (ID, name, expDate, price)
  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  int get totalPrice {
    return _cartItems.fold(0, (prev, item) => prev + item.price);
  }

  void addItem(CartItem item) {
    _cartItems.add(item);
    notifyListeners();
  }

  void removeItem(int index) {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems.removeAt(index);
      notifyListeners();
    }
  }

  void clearBill() {
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
