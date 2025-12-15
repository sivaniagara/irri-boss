import 'package:flutter/material.dart';

class CustomOutlinedButton extends StatelessWidget {
  final String title;
  final void Function()? onPressed;
  const CustomOutlinedButton({super.key, required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        onPressed: onPressed,
        child: Text(title, style: TextStyle(color: Theme.of(context).primaryColor))
    );
  }
}