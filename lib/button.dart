import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  Widget child;

  Button({
    super.key, 
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromRGBO(128, 128, 128, 0.4),
          borderRadius: BorderRadius.circular(16)
        ),
        child: Center(
          child: child,
        )
      )
    );
  }
}