import 'package:flutter/material.dart';
import '../constants/theme.dart';

enum SnackBarType { success, error }

class ShowSnackBar {
  ShowSnackBar._();

  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.success,
  }) {
    final bool isSuccess = type == SnackBarType.success;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          backgroundColor: isSuccess
              ? const Color(0xFFE7F8EE)
              : const Color(0xFFFDECEC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isSuccess
                  ? const Color(0xFF4CAF50).withValues(alpha: 0.18)
                  : const Color(0xFFE53935).withValues(alpha: 0.18),
            ),
          ),
          elevation: 8,
          content: Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                color: isSuccess
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFC62828),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.blackColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
