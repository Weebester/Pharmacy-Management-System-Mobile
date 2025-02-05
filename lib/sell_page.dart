import 'package:flutter/material.dart';

class SellPage extends StatefulWidget {
  const SellPage({super.key});

  @override
  SellPageState createState() => SellPageState();
}

class SellPageState extends State<SellPage> {
  int pharmaIndex = 0;
  late String pharmacy = "";


  List<int> itemIds = [10,20,5];
  List<String> med = ["Paracetamol", "Aspirin", "Ibuprofen"];
  List<String> expDates = ["2025-5-2","2025-4-2","2025-8-27"];
  List<int> prices = [5, 10, 15];


  // Function to add an item to the list
  void addItem(int id, String name, String expDate, int price) {
    setState(() {
      itemIds.add(id);
      med.add(name);
      expDates.add(expDate);
      prices.add(price);
    });
  }

  // Function to remove an item from the list by index
  void removeItem(int index) {
    if (index >= 0 && index < med.length) {
      setState(() {
        itemIds.removeAt(index);
        med.removeAt(index);
        expDates.removeAt(index);
        prices.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  children: List.generate(med.length, (index) {
                    return ListTile(
                      title: Text(med[index]),
                      subtitle: Text("Price: \$${prices[index]}"),
                      onTap: () {
                        removeItem(index);
                        // Handle tap action if needed
                      },
                    );
                  }),
                ),

                const Divider(),
                const SizedBox(height: 10),

                // Total Price Calculation
                Text(
                  "Total Price: \$${prices.fold(0, (prev, price) => prev + price)}",
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
                      onPressed: () {},
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
                      onPressed: () {},
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
  }
}
