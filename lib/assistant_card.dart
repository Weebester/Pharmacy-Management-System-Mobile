import 'package:flutter/material.dart';

class AssistantCard extends StatelessWidget {
  final Assistant assistant;

  const AssistantCard({super.key, required this.assistant});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  assistant.user,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: theme.primaryColor,
                  ),
                ),
                IconButton(onPressed: () {}, icon: Icon(Icons.delete)),
              ],
            ),
            const Divider(),
            Text(
              "Branch: ${assistant.phName}",
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              "Email: ${assistant.email}",
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class Assistant {
  final String fbId;
  final String user;
  final String phName;
  final String email;

  Assistant({
    required this.fbId,
    required this.user,
    required this.phName,
    required this.email,
  });

  factory Assistant.fromJson(Map<String, dynamic> json) {
    return Assistant(
      fbId: json['FB_id'],
      user: json['user'],
      phName: json['phname'],
      email: json['email'],
    );
  }
}
