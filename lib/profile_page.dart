import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api_call_manager.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api_call_manager.dart';
import 'user_state.dart';  // Make sure to import the UserState

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api_call_manager.dart';
import 'user_state.dart';  // Make sure to import the UserState

class ProfilePage extends StatelessWidget {
  final APICaller apiCaller;

  // Constructor that receives the apiCaller instance
  const ProfilePage({super.key, required this.apiCaller});

  Future<Profile> fetchProfile(int pharmaIndex) async {
    String route = "$serverAddress/Profile?pharma_index=$pharmaIndex";

    try {
      final response = await apiCaller.get(route);

      if (response.statusCode == 200) {
        return Profile.fromJson(response.data);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
      return Profile(userName: " ", pharmacy: " ", email: " ", position: " ");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserState>(
      builder: (context, userState, child) {
        // Get pharmaIndex from UserState
        int pharmaIndex = userState.pharmaindex;

        return FutureBuilder<Profile>(
          future: fetchProfile(pharmaIndex), // Fetch profile data when pharmaIndex changes
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return Center(child: Text('No profile data available'));
            }

            Profile profile = snapshot.data!;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Section
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                child: Text(profile.userName[0]),
                              ),
                              const SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile.userName,
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  Text(
                                    profile.email,
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                  Text(
                                    profile.pharmacy,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    profile.position == "Yes" ? "Manager" : "Assistant",
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const Text(
                          "Pharmacists",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        // Notification Section (List)
                        const Text(
                          "Notifications",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class InfoTile extends StatelessWidget {
  final String title;
  final String content;

  const InfoTile({required this.title, required this.content, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(content),
    );
  }
}

class Profile {
  String userName;
  String email;
  String pharmacy;
  String position;

  Profile(
      {required this.userName,
        required this.pharmacy,
        required this.email,
        required this.position});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      userName: json["user_name"],
      email: json["email"],
      pharmacy: json["pharmacy"],
      position: json["position"],
    );
  }
}
