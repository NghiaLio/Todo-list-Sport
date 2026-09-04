// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../widgets/custom_header.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/todos/todosCubit.dart';
import '../bloc/todos/todosState.dart';
import '../bloc/sports/sportsCubit.dart';
import '../bloc/sports/sportsState.dart';

class Statisticalscreen extends StatelessWidget {
  const Statisticalscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.dividerSoftColor,
      appBar: buildAppBar(context, 'STATISTICAL'),
      body: SafeArea(
        child: BlocBuilder<TaskTodoCubit, TodoTaskState>(
          builder: (context, todoState) {
            return BlocBuilder<SportsCubit, SportsState>(
              builder: (context, sportsState) {
                int totalTasks = 0;
                int completedTasks = 0;

                // Todo Tasks Calculation
                if (todoState is TodoTaskLoaded) {
                  totalTasks += todoState.totalCount;
                  completedTasks +=
                      (todoState.totalCount * todoState.completionRate).round();
                }

                // Sports Tasks Calculation
                if (sportsState is SportsLoaded) {
                  totalTasks += sportsState.tasks.length;
                  completedTasks += sportsState.tasks
                      .where((t) => t.isCompleted)
                      .length;
                }

                double progressCompleted = totalTasks == 0
                    ? 0
                    : completedTasks / totalTasks;
                double progressNotStarted = totalTasks == 0
                    ? 0
                    : 1.0 - progressCompleted;

                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _StatRing(
                          progress: progressCompleted,
                          percentageLabel:
                              '${(progressCompleted * 100).round()}%',
                          progressColor: AppTheme.statisticalCompletedColor,
                          title: 'Completed',
                        ),
                        const SizedBox(height: 26),
                        _StatRing(
                          progress: progressNotStarted,
                          percentageLabel:
                              '${(progressNotStarted * 100).round()}%',
                          progressColor: AppTheme.statisticalNotStartedColor,
                          title: 'Not Started',
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _StatRing extends StatelessWidget {
  final double progress;
  final String percentageLabel;
  final Color progressColor;
  final String title;

  const _StatRing({
    required this.progress,
    required this.percentageLabel,
    required this.progressColor,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 170,
          height: 170,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 16,
                  valueColor: AlwaysStoppedAnimation(progressColor),
                  backgroundColor: AppTheme.greyColor.withOpacity(0.2),
                ),
              ),

              Text(
                percentageLabel,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: progressColor,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(),
            ),
          ],
        ),
      ],
    );
  }
}
