import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mypharmacy/user_state.dart';
import 'package:provider/provider.dart';
import 'api_call_manager.dart';
import 'custom_widgets_&_utility.dart';

class MedDetailsPage extends StatelessWidget {
  final int medId;

  const MedDetailsPage({super.key, required this.medId});

  Future<MedDetails?> fetchMedDetails(int medId, APICaller apiCaller) async {
    String route = "$serverAddress/MedDetails?med_id=$medId";

    try {
      final response = await apiCaller.get(route);

      if (response.statusCode == 200) {
        return MedDetails.fromJson(response.data);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<bool> addItem(String med, int price, int medId, int pharmaIndex,
      APICaller apiCaller) async {
    String route = "$serverAddress/insert_item"; // Endpoint for inserting item
    Map<String, dynamic> requestBody = {
      "med": med,
      "price": price,
      "med_id": medId,
      "pharma_index": pharmaIndex
    };

    try {
      final response = await apiCaller.post(route, requestBody);

      if (response.statusCode == 200) {
        print("Item inserted successfully");
        return true;
      } else {
        throw Exception('Failed to insert item');
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
        title: const Text("Medication Details"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: FutureBuilder<MedDetails?>(
        future: fetchMedDetails(medId, apiCaller),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading data"));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No data available"));
          }

          final medDetails = snapshot.data!;

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
                                  color: (medDetails.pom == "Yes")
                                      ? Colors.pink
                                      : Colors.greenAccent,
                                  width: 4),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Image.network(
                              "$serverAddress/MedIMG?ImageId=${medDetails.medId}",
                              fit: BoxFit.fill,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              medDetails.med,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.visible,
                              maxLines: null,
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
                            String price = "";
                            await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Enter Item Price"),
                                  content: TextField(
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: 'Enter item price',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
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
                                          bool success = await addItem(
                                            medDetails.med,
                                            priceValue,
                                            medDetails.medId,
                                            userState.pharmaIndex,
                                            apiCaller,
                                          );

                                          SchedulerBinding.instance
                                              .addPostFrameCallback((_) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  success
                                                      ? 'Med Added!'
                                                      : 'Failed to add Med!',
                                                ),
                                              ),
                                            );
                                            Navigator.pop(context);
                                          });
                                        }
                                      },
                                      child: Text("Add"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'ADD',
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
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text("ID: ${medDetails.medId}",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Manufacturer: ${medDetails.manufacturer}",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Brand: ${medDetails.brand}",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Country: ${medDetails.country}",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("POM: ${medDetails.pom}",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Dosage Form: ${medDetails.form}",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),
                      Divider(),
                      Text(
                        "Ingredients and Information",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      for (int i = 0; i < medDetails.tas.length; i++) ...[
                        Row(
                          children: [
                            Text(
                              medDetails.tas[i],
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              onPressed: () async {
                                final taDetails = await fetchTADetails(
                                    medDetails.taIds[i], apiCaller);
                                SchedulerBinding.instance
                                    .addPostFrameCallback((_) {
                                  showTADetailsDialog(context, taDetails);
                                });
                              },
                              icon: Icon(Icons.info,color: Theme.of(context).colorScheme.primary,),
                            )
                          ],
                        ),
                        Text(
                          "Concentration: ${medDetails.concentrations[i]} (${medDetails.units[i]})",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text("Affects: ${medDetails.effSystems[i]}",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("Addiction: ${medDetails.addiction[i]}",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 16),
                      ],
                      Divider(),
                      Text(
                        "Commercial Alternatives",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      medDetails.altNames.isEmpty
                          ? Text("None")
                          : Column(
                              children: List.generate(
                                medDetails.altNames.length,
                                (index) {
                                  return Container(
                                    margin: EdgeInsets.symmetric(vertical: 4),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          side: BorderSide(
                                              color: Colors.grey, width: 1),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.black54,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 16)),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                MedDetailsPage(
                                              medId: medDetails.altIds[index],
                                            ),
                                          ),
                                        );
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            medDetails.altNames[index],
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          Icon(Icons.arrow_forward_ios,
                                              size: 16),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
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

class MedDetails {
  int medId;
  String med;
  String pom;
  List<String> effSystems;
  List<String> tas;
  List<int> taIds;
  List<String> addiction;
  List<String> concentrations;
  List<String> units;
  String brand;
  String country;
  String manufacturer;
  String form;
  List<int> altIds;
  List<String> altNames;

  MedDetails({
    required this.medId,
    required this.med,
    required this.pom,
    required this.effSystems,
    required this.tas,
    required this.taIds,
    required this.addiction,
    required this.concentrations,
    required this.units,
    required this.brand,
    required this.country,
    required this.manufacturer,
    required this.form,
    required this.altIds,
    required this.altNames,
  });

  factory MedDetails.fromJson(Map<String, dynamic> json) {
    return MedDetails(
      medId: json["Med_id"],
      med: json["Med"],
      pom: json["POM"],
      effSystems: List<String>.from(json["effSystems"]),
      tas: List<String>.from(json["TAs"]),
      taIds: List<int>.from(json["TA_ids"]),
      addiction: List<String>.from(json["Addiction"]),
      concentrations: List<String>.from(json["concentrations"]),
      units: List<String>.from(json["units"]),
      brand: json["Brand"],
      country: json["country"],
      manufacturer: json["manufacturer"],
      form: json["Form"],
      altIds: List<int>.from(json["alt_ids"]),
      altNames: List<String>.from(json["alt_names"]),
    );
  }
}
