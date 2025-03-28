import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LogEntryCard extends StatelessWidget {
  final LogEntry logEntry;

  const LogEntryCard({super.key, required this.logEntry});

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
            Text("On ${formatDate(logEntry.date)}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: theme.colorScheme
                    .primary,
              ),
            ),
            const Divider(),
            Text(
              logEntry.content,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  String formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('yyyy-MM-dd:HH:mm').format(date);
    } catch (e) {
      return dateString; // Fallback if parsing fails
    }
  }
}

class LogEntry {
  final String date;
  final String content;

  LogEntry({required this.date, required this.content});

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      date: json['date'],
      content: json['content'],
    );
  }
}
