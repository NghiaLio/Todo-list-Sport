import 'package:flutter/material.dart';
import '../constants/theme.dart';

class TaskActionButtons extends StatelessWidget {
  final bool isCompleted;
  final bool isRejected;
  final VoidCallback onConfirm;
  final VoidCallback onReject;

  const TaskActionButtons({
    super.key,
    required this.isCompleted,
    required this.isRejected,
    required this.onConfirm,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppTheme.primaryColor;
    final errorColor = AppTheme.errorColor;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Confirm Button
        GestureDetector(
          onTap: onConfirm,
          child: Container(
            width: 54,
            height: 50,
            decoration: BoxDecoration(
              color: isCompleted ? primaryColor : AppTheme.whiteColor,
              border: Border.all(color: primaryColor, width: 2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset('assets/check.png'),
            ),
          ),
        ),
        const SizedBox(width: 6),
        // Reject Button
        GestureDetector(
          onTap: onReject,
          child: Container(
            width: 54,
            height: 50,
            decoration: BoxDecoration(
              color: isRejected ? errorColor : AppTheme.whiteColor,
              border: Border.all(color: errorColor, width: 2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                'assets/delete.png',
                color: isRejected ? AppTheme.whiteColor : errorColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
