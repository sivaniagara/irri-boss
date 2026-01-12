import 'package:flutter/material.dart';

class LeafBox extends StatelessWidget {
  final Widget child;
  const LeafBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      height: 40,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), topRight: Radius.circular(15)),
          border: Border.all(width: 1, color: Theme.of(context).colorScheme.outline)
      ),
      child: child,
    );
  }
}
