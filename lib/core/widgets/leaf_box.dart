import 'package:flutter/material.dart';

class LeafBox extends StatelessWidget {
  final Widget child;
  final double height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  const LeafBox({super.key, required this.child, this.height = 40, this.padding, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.all(10),
      height: height,
      padding: padding,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), topRight: Radius.circular(10)),
          border: Border.all(width: 1, color: Theme.of(context).colorScheme.outline)
      ),
      child: child,
    );
  }
}
