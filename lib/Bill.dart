import 'package:flutter/material.dart';
import 'package:mypharmacy/api_call_manager.dart';

class BillState with ChangeNotifier {
  // List of cart items with their details (ID, name, expDate, price)
  final List<CartItem> _cartItems = [];
  final TextEditingController doc = TextEditingController();

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
    doc.clear();
    notifyListeners();
  }

  Future<Map<String, dynamic>> sell(
      APICaller apiCaller, int pharmaIndex) async {
    String route = "$serverAddress/sell_items";

    if (doc.text.trim().isEmpty) {
      return {"success": false, "message": "Prescriber name is required!"};
    }

    String content = """
prescriber: ${doc.text}
#####
${_cartItems.map((item) => "* ${item.name}\n  ID: ${item.id}\n  POM: ${item.pom}\n  Expiry: ${item.expDate}\n  Price: ${item.price}").join("\n")}
#####
total price: $totalPrice
""";

    Map<String, dynamic> requestBody = {
      "item_ids": _cartItems.map((item) => item.id).toList(),
      "ex_dates": _cartItems.map((item) => item.expDate).toList(),
      "content": content,
      "index": pharmaIndex
    };

    try {
      final response = await apiCaller.put(route, requestBody);

      if (response.statusCode == 200) {
        return {"success": true, "message": "Success"};
      } else {
        return {
          "success": false,
          "message": "Failed to sell items: ${response.data}"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }
}

class CartItem {
  final int id;
  final String name;
  final String pom;
  final String expDate;
  final int price;

  CartItem({
    required this.id,
    required this.name,
    required this.pom,
    required this.expDate,
    required this.price,
  });
}
