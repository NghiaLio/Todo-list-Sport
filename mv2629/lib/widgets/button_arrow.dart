// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:mv2629/constants/theme.dart';

class ButtonArrow extends StatelessWidget {
  final VoidCallback? onPressed;
  final String iconAsset;
  final double size;
  const ButtonArrow({
    super.key,
    this.onPressed,
    this.iconAsset = 'assets/leftArrow.png',
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed ?? () => Navigator.of(context).pop(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.white20Color,
        ),
        child: Image.asset(iconAsset, fit: BoxFit.contain),
      ),
    );
  }
}
