import 'package:flutter/material.dart';
import 'package:mypharmacy/api_call_manager.dart';
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

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
                  decoration: InputDecoration(
                    labelText: "Medicine",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  onChanged: (value) {
                    med = value;
                  },
                ),
                SizedBox(height: 5),
                TextField(
                  decoration: InputDecoration(
                    labelText: "Manufacturer",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  onChanged: (value) {
                    manufacturer = value;
                  },
                ),
                SizedBox(height: 5),
                TextField(
                  decoration: InputDecoration(
                    labelText: "Country",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  onChanged: (value) {
                    country = value;
                  },
                ),
                SizedBox(height: 5),
                TextField(
                  decoration: InputDecoration(
                    labelText: "Therapeutic Agent",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
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
    return null;
  }
}

void showTADetailsDialog(BuildContext context, TADetails? taDetails) {
  if (taDetails == null) {
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
            ),
          ),
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
