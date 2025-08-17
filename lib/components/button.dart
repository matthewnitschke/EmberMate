import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  Widget child;
  double? width;
  double? height;
  bool isSelected;
  VoidCallback? onTap;

  Button({
    super.key, 
    required this.child,
    this.width,
    this.height,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(10);

    final defaultColor = Colors.black.withValues(alpha: 0.29);
    final activeColor = Colors.black.withValues(alpha: 0.7);

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        textStyle: TextStyle(color: Colors.white),
        color: isSelected
          ? activeColor
          : defaultColor,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap ?? () {},
          highlightColor: activeColor,
          borderRadius: radius,
          splashColor: Colors.transparent,
          child: Center(
            child: child,
          )
        ),
      ),
    );
  }
}