import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mypharmacy/custom_widgets_&_utility.dart';
import 'api_call_manager.dart';
import 'med_details_page.dart';

class ItemDetailsPage extends StatelessWidget {
  final StockItem item;
  final DateTime now;
  final DateTime fourMonthsFromNow;

  // Constructor to initialize the page with item and calculated dates
  ItemDetailsPage({super.key, required this.item})
      : now = DateTime.now(),
        fourMonthsFromNow = DateTime.now().add(const Duration(days: 120));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Item Details"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(horizontal: 8),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: (item.pom == "Yes")
                                  ? Colors.pink
                                  : Colors.greenAccent,
                              width: 4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Image.network(
                          "$serverAddress/MedIMG?ImageId=${item.medId}",
                          fit: BoxFit.fill,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.med,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.visible,
                                maxLines: null,
                              ),
                            ),
                            IconButton(
                              icon:
                                  Icon(Icons.info_outline, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MedDetailsPage(medId: item.medId),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    // Make it take almost full width
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    // Optional padding to adjust button's width
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: Text(
                        'Remove',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Divider(),
                  Text(
                    "Basic Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text("ID: ${item.medId}",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("Manufacturer: ${item.manufacturer}",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("Country: ${item.country}",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("POM: ${item.pom}",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Text(
                        "Price: ${item.price} IQD",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.edit),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Divider(),
                  Row(
                    children: [
                      Text(
                        "Batches",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  for (var batch in item.batches) ...[
                    Row(
                      children: [
                        Text(
                          "ExpDate: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(batch["EXDate"]))}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: DateTime.parse(batch["EXDate"]).isBefore(now)
                                ? Colors.red // Expired
                                : DateTime.parse(batch["EXDate"])
                                        .isBefore(fourMonthsFromNow)
                                    ? Colors.orange // 4 months to expire
                                    : (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white // Use white in dark mode
                                        : Colors
                                            .black), // Default black color in light mode
                          ),
                        ),
                        Text(
                          " (${batch["count"]})",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () {
                            // Your delete logic here
                          },
                          icon: Icon(Icons.delete),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}