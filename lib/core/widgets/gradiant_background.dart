import 'package:flutter/material.dart';

class GradiantBackground extends StatelessWidget {
  final Widget child;
  const GradiantBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xffC6DDFF),
              Color(0xff67C8F1),
              Color(0xff6DA8F5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
      ),
      child: child,
    );
  }
}
