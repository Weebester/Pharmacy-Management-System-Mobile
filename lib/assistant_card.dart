import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'api_call_manager.dart';

class AssistantCard extends StatelessWidget {
  final APICaller apiCaller;
  final Assistant assistant;
  final Function updateList;

  const AssistantCard(
      {super.key,
      required this.assistant,
      required this.apiCaller,
      required this.updateList});

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
                    color: theme.colorScheme
                        .primary,
                  ),
                ),
                IconButton(
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Confirm Action'),
                            content: Text(
                                'Are you sure you want to add this assistant?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                // Close dialog
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  try {
                                    await deleteAssistant(
                                        assistant.user,
                                        assistant.fbId,
                                        assistant.phId,
                                        apiCaller);
                                    SchedulerBinding.instance
                                        .addPostFrameCallback((_) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Assistant deleted successfully')),
                                      );
                                      Navigator.of(context).pop();
                                    });
                                  } catch (e) {
                                    SchedulerBinding.instance
                                        .addPostFrameCallback((_) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content:
                                                Text('Error: ${e.toString()}')),
                                      );
                                      Navigator.of(context).pop();
                                    });
                                  }
                                  updateList();
                                },
                                child: Text('Confirm'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: Icon(Icons.delete)),
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

  Future<void> deleteAssistant(
      String name, String fbId, int phId, APICaller apiCaller) async {
    String route = "$serverAddress/delete_assistant";
    Map<String, dynamic> requestBody = {
      "phid": phId,
      "name": name,
      "FB_id": fbId,
    };

    try {
      final response = await apiCaller.delete(route, requestBody);

      if (response.statusCode == 200) {
      } else {
        throw Exception('Failed to delete assistant');
      }
    } catch (e) {
      print('Failed to delete assistant');
      rethrow;
    }
  }
}

class Assistant {
  final String fbId;
  final String user;
  final String phName;
  final String email;
  final int phId;

  Assistant(
      {required this.fbId,
      required this.user,
      required this.phName,
      required this.email,
      required this.phId});

  factory Assistant.fromJson(Map<String, dynamic> json) {
    return Assistant(
      fbId: json['FB_id'],
      user: json['user'],
      phName: json['phname'],
      email: json['email'],
      phId: json['PH_id'],
    );
  }
}
