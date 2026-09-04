import 'package:flutter/material.dart';
import '../constants/theme.dart';

class CustomFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CustomFloatingActionButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(16, 0),
      child: SizedBox(
        width: 90,
        height: 56,
        child: FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: AppTheme.whiteColor,
          elevation: 2,
          heroTag: null,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(left: Radius.circular(30)),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Icon(Icons.add, color: AppTheme.blackColor, size: 30),
          ),
        ),
      ),
    );
  }
}
