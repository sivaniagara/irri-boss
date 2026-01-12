import 'package:flutter/material.dart';

class CustomMaterialButton extends StatelessWidget {
  final String title;
  final void Function()? onPressed;
  const CustomMaterialButton({super.key, required this.onPressed, required this.title});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: Theme.of(context).primaryColor,
        onPressed: onPressed,
      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
      child: Text(title, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white),),
    );
  }
}
