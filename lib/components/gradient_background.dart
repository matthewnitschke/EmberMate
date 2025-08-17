import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final Color topColor;
  final Color bottomColor;

  const GradientBackground({
    super.key,
    required this.child,
    required this.topColor,
    required this.bottomColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      textStyle: TextStyle(
        color: Colors.white
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [topColor, bottomColor],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: child,
        ),
      ),
    );
  }
}
