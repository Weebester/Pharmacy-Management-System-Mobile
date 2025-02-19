import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'api_call_manager.dart';
import 'user_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<Profile> fetchProfile(int pharmaIndex, APICaller apiCaller) async {
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

  Future<List<Map<String, dynamic>>> fetchLatest(
      int pharmaIndex, APICaller apiCaller) async {
    String route = "$serverAddress/update_logs?pharma_index=$pharmaIndex";

    try {
      final response = await apiCaller.get(route);

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiCaller = context.read<APICaller>();
    return Consumer<UserState>(
      builder: (context, userState, child) {
        int pharmaIndex = userState.pharmaIndex;

        return FutureBuilder<Profile>(
          future: fetchProfile(pharmaIndex, apiCaller),
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
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  Text(
                                    profile.email,
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                  Text(
                                    profile.pharmacy,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    profile.position == "Yes"
                                        ? "Manager"
                                        : "Assistant",
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
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
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: fetchLatest(userState.pharmaIndex, apiCaller),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text("Failed to load notifications"));
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Center(
                                  child: Text("No notifications available"));
                            }

                            return ListView(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              children: snapshot.data!.map((notification) {
                                DateTime parsedDate = DateTime.parse(notification["date"]);
                                String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
                                String formattedTime = DateFormat('HH:mm').format(parsedDate);

                                return [
                                  Text(
                                    "On $formattedDate at $formattedTime:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  Text(notification["content"] ?? "No content"),
                                  SizedBox(height: 10),
                                ];
                              }).expand((widget) => widget).toList()
                            );
                          },
                        ),
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
