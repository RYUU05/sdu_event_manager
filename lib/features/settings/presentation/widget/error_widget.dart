import 'package:flutter/material.dart';

class ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorWidget({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 64),
          SizedBox(height: 16),
          Text('Something wrong cuhh'),
          SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onRetry,
            icon: Icon(Icons.refresh),
            label: Text('Refresh'),
          ),
        ],
      ),
    );
  }
}
