import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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

  @override
  Widget build(BuildContext context) {
    final apiCaller = context.read<APICaller>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Medication Details"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
                        // Make it take almost full width
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        // Optional padding to adjust button's width
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
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
                                icon: Icon(Icons.info))
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
