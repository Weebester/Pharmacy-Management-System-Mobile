import 'package:flutter/material.dart';

class BranchSS extends StatelessWidget {
  const BranchSS({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager Page'),
      ),
      body: const Center(
        child: Text(
          'Manager',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
