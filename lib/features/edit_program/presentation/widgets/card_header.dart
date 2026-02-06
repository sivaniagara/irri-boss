import 'package:flutter/material.dart';

class CardHeader extends StatelessWidget {
  final bool open;
  final String title;
  void Function()? onPressed;
  CardHeader({
    super.key,
    required this.title,
    required this.onPressed, required this.open,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const Spacer(),
        const SizedBox(width: 12),
        IconButton(
            onPressed: onPressed,
            icon: Icon(open ? Icons.keyboard_arrow_up_outlined : Icons.keyboard_arrow_down_outlined, size: 28, color: Colors.black,)
        ),
      ],
    );
  }
}
