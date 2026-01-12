import 'package:flutter/material.dart';

class SharpRadiusCard extends StatelessWidget {
  final Widget child;
  const SharpRadiusCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
        border: Border.all(color: Theme.of(context).colorScheme.outline)
      ),
        child: child,
    );
  }
}
