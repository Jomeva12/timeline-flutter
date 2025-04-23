import 'package:flutter/material.dart';

class ErrorCard extends StatelessWidget {
  final List<String> errors;
  const ErrorCard({super.key, required this.errors});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red[50],
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: errors.map((e) => Text('• $e')).toList(),
        ),
      ),
    );
  }
}