import 'package:flutter/material.dart';
import 'package:mypharmacy/state_manager.dart';
import 'package:provider/provider.dart';
import 'api_call_manager.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  Profile profile = Profile(userName: " ", pharmacy: " ", position: " ");

  Future<Profile> fetchProfile(int pharmaIndex) async {
    String route =
        "$serverAddress/Profile?pharma_index=$pharmaIndex";

    try {
      final apiCaller = context.read<APICaller>();
      final response = await apiCaller.get(route);

      if (response.statusCode == 200) {
        return Profile.fromJson(response.data);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');

      return profile;
    }
  }

  List<String> notifications = [
    "Order #1234 has been processed",
    "Inventory check required",
    "New shift assigned: 2 PM - 10 PM",
    "Meeting scheduled at 3 PM",
  ];

  void addNotification(String notification) {
    setState(() {
      notifications.add(notification);
    });
  }

  @override
  void initState() {
    super.initState();
    final userState = context.read<StateManager>();
    fetchProfile(userState.pharmacyIndex).then((result) {
      setState(() {
        profile = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Row(
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
                        maxLines: null,
                      ),
                      Text(
                        profile.pharmacy,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: null,
                      ),
                      Text(
                        profile.position,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: null,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Divider(),

              // Change Password Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Example action: Add a new notification
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text("Password change feature coming soon!")),
                    );
                  },
                  child: const Text("Change Password"),
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
              ...notifications.map((notification) => InfoTile(
                    title: notification,
                    content: '',
                  )),
            ],
          ),
        ),
      ),
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
  String pharmacy;
  String position;

  Profile(
      {required this.userName, required this.pharmacy, required this.position});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      userName: json["user_name"],
      pharmacy: json["pharmacy"],
      position: json["position"],
    );
  }
}
