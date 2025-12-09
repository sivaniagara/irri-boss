import 'package:flutter/material.dart';

class GlassyWrapper extends StatelessWidget {
  final Widget? child;

  const GlassyWrapper({
    super.key,
    this.child,
  });

  @override
  Widget build(BuildContext dialogContext) {
    List<Widget> stackChildren = [
      Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(dialogContext).colorScheme.primaryContainer,
                Colors.black87,
              ],
            ),
          ),
        ),
      ),
    ];

    // Child content layer
    stackChildren.add(Positioned.fill(child: child!));

    return Stack(
      children: stackChildren,
    );
  }

}