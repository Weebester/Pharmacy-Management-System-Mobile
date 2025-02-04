import 'package:flutter/material.dart';
import 'package:mypharmacy/api_call_manager.dart';
import 'Item_details_page.dart';
import 'med_details_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferences {
  static const String _key = "theme_mode";

  Future<void> saveTheme(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, isDarkMode);
  }

  Future<bool> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }
}

///////////////////////////////////////////////////////////MedView/////////////////////////////////////////////////////////////

class MedView extends StatelessWidget {
  const MedView({super.key, required this.med});

  final Med med;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MedDetailsPage(medId: med.id),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(2),
          child: Card(
            elevation: 10,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: (med.pom == "Yes")
                              ? Colors.pink
                              : Colors.greenAccent,
                          width: 4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.network(
                      "$serverAddress/MedIMG?ImageId=${med.id}",
                      fit: BoxFit.fill,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          "Assets/placeholder.png", // Path to fallback image
                          fit: BoxFit.fill,
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(med.med,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center),
                        Text(
                          "\u{1F3ED}: ${med.manufacturer}",
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "\u{1F30D}: ${med.country}",
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      if (med.brand == "Yes")
        Positioned(
          bottom: 12,
          right: 12,
          child: SizedBox(
            width: 24,
            height: 24,
            child: Center(
              child: Text(
                "\u{1F48E}",
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
        ),
    ]);
  }
}

class Med {
  int id;
  String med;
  String manufacturer;
  String country;
  String pom;
  String brand;

  Med(
      {required this.id,
      required this.med,
      required this.manufacturer,
      required this.country,
      required this.pom,
      required this.brand});

  factory Med.fromJson(Map<String, dynamic> json) {
    return Med(
      id: json["MED_id"],
      med: json["Med"],
      brand: json["Brand"],
      pom: json["POM"],
      manufacturer: json["Manufacturer"],
      country: json["Country"],
    );
  }
}

void search(
    BuildContext context, Function(String, String, String, String) update) {
  String med = "";
  String manufacturer = "";
  String country = "";
  String ta = "";
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Search Menu"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: "Medicine"),
                  onChanged: (value) {
                    med = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Manufacturer"),
                  onChanged: (value) {
                    manufacturer = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Country"),
                  onChanged: (value) {
                    country = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Therapeutic Agent"),
                  onChanged: (value) {
                    ta = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();

                  update(med, manufacturer, country, ta);
                },
                child: Text("Search"))
          ],
        );
      });
}

///////////////////////////////////////////////////////////TADetails/////////////////////////////////////////////////////////////

Future<TADetails?> fetchTADetails(int taId, APICaller apiCaller) async {
  String route = "$serverAddress/TADetails?ta_id=$taId";

  try {
    final response = await apiCaller.get(route);

    if (response.statusCode == 200) {
      return TADetails.fromJson(response.data);
    } else {
      throw Exception('Failed to load data');
    }
  } catch (e) {
    print('Error: $e');
    return null; // Return null in case of failure
  }
}

void showTADetailsDialog(BuildContext context, TADetails? taDetails) {
  if (taDetails == null) {
    // Show error dialog if no data
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text("Failed to load therapeutic agent details."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  } else {
    // Show details dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Therapeutic Agent Details"),
          content: SingleChildScrollView(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Therapeutic Agent: ${taDetails.ta}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "Side Effects:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ...taDetails.se.map((se) => Text("- $se")),
              SizedBox(height: 8),
              Text(
                "Contraindications:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ...taDetails.cc.map((cc) => Text("- $cc")),
              SizedBox(height: 8),
              Text(
                "Food Considerations:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ...taDetails.fc.map((fc) => Text("- $fc")),
              SizedBox(height: 8),
              Text(
                "Drug-Drug Interactions:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ...taDetails.ddi.map((ddi) => Text("- $ddi")),
            ],
          )),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }
}

class TADetails {
  String ta;
  List<String> se;
  List<String> cc;
  List<String> fc;
  List<String> ddi;

  TADetails({
    required this.ta,
    required this.se,
    required this.cc,
    required this.fc,
    required this.ddi,
  });

  factory TADetails.fromJson(Map<String, dynamic> json) {
    return TADetails(
      ta: json["TA"],
      se: List<String>.from(json["SE"]),
      cc: List<String>.from(json["CC"]),
      fc: List<String>.from(json["FC"]),
      ddi: List<String>.from(json["DDI"]),
    );
  }
}

///////////////////////////////////////////////////////////ItemView/////////////////////////////////////////////////////////////
class ItemView extends StatelessWidget {
  const ItemView({super.key, required this.item});

  final StockItem item;

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
                      onTap: () {},
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
                })
              ,
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
  List<Map<String, dynamic>> batches;  // Add batches field

  StockItem({
    required this.itemID,
    required this.medId,
    required this.med,
    required this.manufacturer,
    required this.country,
    required this.pom,
    required this.price,
    required this.batches,  // Update constructor
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
      batches: List<Map<String, dynamic>>.from(json["batches"])  // If no batches, return empty list
    );
  }
}

