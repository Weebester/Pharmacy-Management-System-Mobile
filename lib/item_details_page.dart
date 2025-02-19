import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:mypharmacy/user_state.dart';
import 'package:provider/provider.dart';
import 'stock_card.dart';
import 'api_call_manager.dart';
import 'med_details_page.dart';

class ItemDetailsPage extends StatefulWidget {
  final StockItem item;
  final Function() refresh;

  const ItemDetailsPage({super.key, required this.item,required this.refresh});

  @override
  ItemDetailsPageState createState() => ItemDetailsPageState();
}

class ItemDetailsPageState extends State<ItemDetailsPage> {
  late StockItem item;
  late DateTime now;
  late DateTime fourMonthsFromNow;

  @override
  @override
  void initState() {
    item = widget.item;
    super.initState();
    now = DateTime.now();
    fourMonthsFromNow = now.add(const Duration(days: 120));
  }

  Future<bool> deleteItem(
      String med, int itemId, int pharmaIndex, APICaller apiCaller) async {
    String route = "$serverAddress/delete_item"; // Endpoint for deleting item
    Map<String, dynamic> requestBody = {
      "med": med,
      "Item_Id": itemId,
      "pharma_index": pharmaIndex
    };

    try {
      final response = await apiCaller.delete(route, data: requestBody);

      if (response.statusCode == 200) {
        print("Item deleted successfully");
        return true;
      } else {
        throw Exception('Failed to delete item');
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiCaller = context.read<APICaller>();
    final userState = context.read<UserState>();
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
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: ElevatedButton(
                      onPressed: () async {
                        bool success = await deleteItem(item.med, item.itemID,
                            userState.pharmaIndex, apiCaller);

                        SchedulerBinding.instance.addPostFrameCallback((_) {
                          if (success) {
                            widget.refresh();
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Item removed successfully!')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to remove item!')),
                            );
                          }
                        });
                      },
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
                                ? Colors.red
                                : DateTime.parse(batch["EXDate"])
                                        .isBefore(fourMonthsFromNow)
                                    ? Colors.orange
                                    : (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black),
                          ),
                        ),
                        Text(
                          " (${batch["count"]})",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () {},
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
