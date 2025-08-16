import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  Widget child;
  double? width;
  double? height;
  bool? isSelected;
  VoidCallback? onTap;

  Button({
    super.key, 
    required this.child,
    this.width,
    this.height,
    this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.black.withValues(alpha: 0.29),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap ?? () {},
          highlightColor: Colors.black.withValues(alpha: .7),
          borderRadius: BorderRadius.circular(8),
          splashColor: Colors.transparent,
          child: Center(
            child: child,
          )
        ),
      ),
    );
  }
}