import 'package:flutter/material.dart';

import '../theme/app_themes.dart';

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
                // Color(0xffC6DDFF),
                // Color(0xff67C8F1),
                // Color(0xff6DA8F5),
                AppThemes.gradientTopColor,
                AppThemes.gradientMidColor,
                AppThemes.gradientBottomColor,
              /*  Theme.of(dialogContext).colorScheme.primaryContainer,
                Colors.black87,*/
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