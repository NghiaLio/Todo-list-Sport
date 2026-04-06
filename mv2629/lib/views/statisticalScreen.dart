// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:mv2629/constants/theme.dart';
import 'package:mv2629/widgets/custom_header.dart';

class Statisticalscreen extends StatelessWidget {
  const Statisticalscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.dividerSoftColor,
      appBar: buildAppBar(context, 'STATISTICAL'),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StatRing(
                  progress: 0.84,
                  percentageLabel: '84%',
                  progressColor: AppTheme.statisticalCompletedColor,
                  title: 'Completed',
                ),
                SizedBox(height: 26),
                _StatRing(
                  progress: 0.13,
                  percentageLabel: '13%',
                  progressColor: AppTheme.statisticalNotStartedColor,
                  title: 'Not Started',
                ),
              ],
            ),
          ),
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
