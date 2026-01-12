import 'package:flutter/material.dart';

class CustomOutlinedButton extends StatelessWidget {
  final String title;
  final void Function()? onPressed;
  const CustomOutlinedButton({super.key, required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.white),
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(vertical: 10, horizontal: 50),
          ),
          shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                side: BorderSide(color: Theme.of(context).colorScheme.primary),
                  borderRadius: BorderRadius.circular(8),
              )
          )
        ),
        child: Text(title, style: Theme.of(context).textTheme.labelLarge)
    );
  }
}