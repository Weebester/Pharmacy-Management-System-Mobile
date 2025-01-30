import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api_call_manager.dart';
import 'med_details_page.dart';

class ItemDetailsPage extends StatelessWidget {
  final String itemId;

  const ItemDetailsPage({super.key, required this.itemId});

  Future<ItemDetails?> fetchItemDetails(String itemId, APICaller apiCaller) async {
    String route = "$serverAddress/StockItem?item_id=$itemId";

    try {
      final response = await apiCaller.get(route);

      if (response.statusCode == 200) {
        return ItemDetails.fromJson(response.data);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiCaller = context.read<APICaller>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Item Details"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<ItemDetails?>(
        future: fetchItemDetails(itemId, apiCaller),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading data"));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No data available"));
          }

          final itemDetails = snapshot.data!;
          DateTime now = DateTime.now();

          return Center(
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
                                  color: (itemDetails.pom == "Yes")
                                      ? Colors.pink
                                      : Colors.greenAccent,
                                  width: 4),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Image.network(
                              "$serverAddress/MedIMG?ImageId=${itemDetails.referenceId}",
                              fit: BoxFit.fill,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    itemDetails.med,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.visible,
                                    maxLines: null,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.info_outline, color: Colors.blue),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MedDetailsPage(medId: itemDetails.referenceId),
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
                      Divider(),
                      Text(
                        "Basic Details",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text("ID: ${itemDetails.referenceId}",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Manufacturer: ${itemDetails.manufacturer}",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Country: ${itemDetails.country}",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("POM: ${itemDetails.pom}",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Price: \$${itemDetails.priceTag}",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),
                      Divider(),
                      Text(
                        "Batches",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      for (var batch in itemDetails.batches) ...[
                        Text(
                          "Expiry Date: ${batch.expiryDate}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: DateTime.parse(batch.expiryDate).isBefore(now) ? Colors.red : Colors.black,
                          ),
                        ),
                        Text(
                          "Stock: ${batch.stockCounter}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ItemDetails {
  int referenceId;
  String med;
  String pom;
  String manufacturer;
  String country;
  int priceTag;
  List<Batch> batches;

  ItemDetails({
    required this.referenceId,
    required this.med,
    required this.pom,
    required this.manufacturer,
    required this.country,
    required this.priceTag,
    required this.batches,
  });

  factory ItemDetails.fromJson(Map<String, dynamic> json) {
    return ItemDetails(
      referenceId: json["reference_id"],
      med: json["med"],
      pom: json["pom"],
      manufacturer: json["manufacturer"],
      country: json["country"],
      priceTag: json["price_tag"],
      batches: (json["batches"] as List)
          .map((batch) => Batch.fromJson(batch))
          .toList(),
    );
  }
}

class Batch {
  String expiryDate;
  int stockCounter;

  Batch({required this.expiryDate, required this.stockCounter});

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      expiryDate: json["expiry_date"],
      stockCounter: json["stock_counter"],
    );
  }
}
