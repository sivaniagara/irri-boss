import 'package:flutter/material.dart';

class Retry extends StatelessWidget {
  final String message;
  final void Function() onPressed;
  const Retry({super.key, required this.message, required this.onPressed});

  @override
  Widget build(BuildContext dialogContext) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Error: $message'),
          ElevatedButton(
            onPressed: onPressed,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
