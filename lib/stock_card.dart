import 'package:flutter/material.dart';
import 'package:mypharmacy/Bill.dart';

import 'item_details_page.dart';
import 'api_call_manager.dart';

class ItemView extends StatelessWidget {
  const ItemView({super.key, required this.item, required this.bill});

  final StockItem item;
  final BillState bill;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: ExpansionTile(
            title: Text(
              item.med,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            subtitle: Text(
              "IQD:${item.price}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            leading: Container(
              margin: EdgeInsets.all(1),
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                border: Border.all(
                  color: (item.pom == "Yes") ? Colors.pink : Colors.greenAccent,
                  width: 4,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Image.network(
                "$serverAddress/MedIMG?ImageId=${item.medId}",
                fit: BoxFit.fill,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    "Assets/placeholder.png",
                    fit: BoxFit.fill,
                  );
                },
              ),
            ),
            children: [
              if (item.batches.isNotEmpty)
                ...item.batches.map((batch) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      onTap: () {
                        bill.addItem(CartItem(
                            id: item.itemID,
                            name: item.med,
                            expDate: batch["EXDate"],
                            price: item.price));
                      },
                      leading: const Icon(
                        Icons.monetization_on,
                        size: 30,
                      ),
                      title: Text(
                        "EXP: ${batch["EXDate"]}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      subtitle: Text(
                        "Count: ${batch["count"]}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                }),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItemDetailsPage(item: item),
                      ),
                    );
                  },
                  leading: const Icon(
                    Icons.edit,
                    size: 30,
                  ),
                  title: Text(
                    "Details",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StockItem {
  int itemID;
  int medId;
  String med;
  String manufacturer;
  String country;
  String pom;
  int price;
  List<Map<String, dynamic>> batches;

  StockItem({
    required this.itemID,
    required this.medId,
    required this.med,
    required this.manufacturer,
    required this.country,
    required this.pom,
    required this.price,
    required this.batches,
  });

  factory StockItem.fromJson(Map<String, dynamic> json) {
    return StockItem(
        itemID: json["Item_id"],
        medId: json["Med_id"],
        med: json["Med"],
        manufacturer: json["Manufacturer"],
        country: json["Country"],
        pom: json["Pom"],
        price: json["Price"],
        batches: List<Map<String, dynamic>>.from(
            json["batches"]) // If no batches,then empty list
        );
  }
}
