import 'package:flutter/material.dart';
import 'api_call_manager.dart';
import 'med_details_page.dart';

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
                          "Assets/placeholder.png",
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
