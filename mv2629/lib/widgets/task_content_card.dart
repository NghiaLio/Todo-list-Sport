import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../widgets/task_action_buttons.dart';

class TaskContentCard extends StatelessWidget {
  final String taskName;
  final String content;
  final String time;
  final bool isCompleted;
  final bool isRejected;
  final VoidCallback onConfirm;
  final VoidCallback onReject;

  const TaskContentCard({
    super.key,
    required this.taskName,
    required this.content,
    required this.time,
    required this.isCompleted,
    required this.isRejected,
    required this.onConfirm,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: AppTheme.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorderColor, width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(50),
            ),
            alignment: Alignment.center,
            child: Text(
              taskName,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.grey600Color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Time: $time',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.grey400Color,
                          // fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: TaskActionButtons(
                  isCompleted: isCompleted,
                  isRejected: isRejected,
                  onConfirm: onConfirm,
                  onReject: onReject,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
