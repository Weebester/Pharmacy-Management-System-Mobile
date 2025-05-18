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

  const ItemDetailsPage({super.key, required this.item, required this.refresh});

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
      final response = await apiCaller.delete(route, requestBody);

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

  Future<bool> deleteBatch(String med, int itemId, String date, int pharmaIndex,
      APICaller apiCaller) async {
    String route = "$serverAddress/delete_batch";
    Map<String, dynamic> requestBody = {
      "item_id": itemId,
      "ex_date": date,
      "med": med,
      "pharma_index": pharmaIndex
    };

    try {
      final response = await apiCaller.delete(route, requestBody);

      if (response.statusCode == 200) {
        print("batch deleted successfully");
        return true;
      } else {
        throw Exception('Failed to batch item');
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<bool> addBatch(String med, int itemId, String date, int count,
      int pharmaIndex, APICaller apiCaller) async {
    String route = "$serverAddress/insert_batch";
    Map<String, dynamic> requestBody = {
      "item_id": itemId,
      "ex_date": date,
      "count": count,
      "med": med,
      "pharma_index": pharmaIndex
    };

    try {
      final response = await apiCaller.post(route, requestBody);

      if (response.statusCode == 200) {
        print("batch deleted successfully");
        return true;
      } else {
        throw Exception('Failed to batch item');
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<bool> changePrice(String med, int itemId, int price, int pharmaIndex,
      APICaller apiCaller) async {
    String route = "$serverAddress/changePrice";
    Map<String, dynamic> requestBody = {
      "item_id": itemId,
      "newPrice": price,
      "med": med,
      "index": pharmaIndex
    };

    try {
      final response = await apiCaller.put(route, requestBody);

      if (response.statusCode == 200) {
        print("batch deleted successfully");
        return true;
      } else {
        throw Exception('Failed to batch item');
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<void> updateBatches(int itemId, APICaller apiCaller) async {
    String route =
        "$serverAddress/ItemBatches?item_id=$itemId"; // Endpoint for deleting item

    try {
      final response = await apiCaller.get(route);

      if (response.statusCode == 200) {
        setState(() {
          item.batches = List<Map<String, dynamic>>.from(response.data);
        });
      } else {
        throw Exception('Failed to delete item');
      }
    } catch (e) {
      print('Error: $e');
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
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
                              icon: Icon(Icons.info,
                                  color: Theme.of(context).colorScheme.primary),
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
                        bool confirmDelete = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Confirm Deletion"),
                              content: Text(
                                  "Are you sure you want to remove this item?"),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text("Delete"),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmDelete == true) {
                          bool success = await deleteItem(item.med, item.itemID,
                              userState.pharmaIndex, apiCaller);

                          SchedulerBinding.instance.addPostFrameCallback((_) {
                            if (success) {
                              widget.refresh();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Item removed successfully!')),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Failed to remove item!')),
                              );
                            }
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
                  if (item.obsolete == "Yes") Text("This Medicine is Obsolete \u26A0\uFE0F",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Text(
                        "Price: ${item.price} IQD",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () async {
                          String price = "";
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Change Price"),
                                content: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'New Price',
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    price = value;
                                  },
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      int? priceValue = int.tryParse(price);
                                      if (priceValue != null) {
                                        bool success = await changePrice(
                                            item.med,
                                            item.itemID,
                                            priceValue,
                                            userState.pharmaIndex,
                                            apiCaller);
                                        if (success){
                                          setState(() {
                                            item.price=priceValue;
                                          });
                                        }
                                        SchedulerBinding.instance
                                            .addPostFrameCallback((_) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                success
                                                    ? 'price changed!'
                                                    : 'Failed to change!',
                                              ),
                                            ),
                                          );
                                          Navigator.pop(context);
                                        });
                                      }
                                    },
                                    child: Text("Change"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: Icon(Icons.edit,
                            color: Theme.of(context).colorScheme.primary),
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
                        onPressed: () async {
                          String exDate = "";
                          String count = "";
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Add Batch"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      keyboardType: TextInputType.datetime,
                                      decoration: InputDecoration(
                                        labelText: 'EXDate (yyyy-mm-dd)',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        exDate = value;
                                      },
                                    ),
                                    SizedBox(height: 10),
                                    TextField(
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'count',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        count = value;
                                      },
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      int? countValue = int.tryParse(count);
                                      DateTime? parsedDate;

                                      try {
                                        parsedDate = DateTime.parse(exDate);
                                      } catch (e) {
                                        parsedDate = null;
                                      }

                                      if (countValue != null &&
                                          parsedDate != null) {
                                        bool success = await addBatch(
                                          item.med,
                                          item.itemID,
                                          exDate,
                                          countValue,
                                          userState.pharmaIndex,
                                          apiCaller,
                                        );
                                        SchedulerBinding.instance
                                            .addPostFrameCallback((_) {
                                          if (success) {
                                            widget.refresh();
                                            updateBatches(
                                                item.itemID, apiCaller);
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Batch added successfully!'),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Failed to add batch! Please try again.'),
                                              ),
                                            );
                                            Navigator.pop(context);
                                          }
                                        });
                                      } else {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Invalid input! Ensure date is in YYYY-MM-DD format.'),
                                          ),
                                        );
                                      }
                                    },
                                    child: Text("Add"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: Icon(Icons.add_circle,
                            color: Theme.of(context).colorScheme.primary),
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
                          onPressed: () async {
                            bool confirmDelete = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Confirm Deletion"),
                                  content: Text(
                                      "Are you sure you want to remove this batch?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: Text("Delete"),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirmDelete == true) {
                              bool success = await deleteBatch(
                                  item.med,
                                  item.itemID,
                                  batch["EXDate"],
                                  userState.pharmaIndex,
                                  apiCaller);

                              SchedulerBinding.instance
                                  .addPostFrameCallback((_) {
                                if (success) {
                                  widget.refresh();
                                  updateBatches(item.itemID, apiCaller);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Batch removed successfully!')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Failed to remove batch!')),
                                  );
                                }
                              });
                            }
                          },
                          icon: Icon(Icons.delete,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
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
