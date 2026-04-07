// ignore_for_file: use_build_context_synchronously, deprecated_member_use, file_names

import 'package:flutter/material.dart';
import 'package:mv2629/constants/theme.dart';
import 'package:mv2629/widgets/button_arrow.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  void _navigateToHome(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Phần trên: Illustrations
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: const _IllustrationWidget(),
            ),
          ),
          // Phần giữa: Text content
          const _TextContentWidget(),
          SizedBox(height: 60),
          ButtonArrow(
            onPressed: () => _navigateToHome(context),
            iconAsset: 'assets/rightArrow.png',
            size: 69,
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }

}

class _IllustrationWidget extends StatelessWidget {
  const _IllustrationWidget();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Image.asset('assets/logo.png', width: 298, height: 298),
    );
  }
}

class _TextContentWidget extends StatelessWidget {
  const _TextContentWidget();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Column(
        children: [
          Text(
            'Welcome to To-do \nList',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: AppTheme.blackColor,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            'where your plans come into\nfocus!',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.displaySmall?.copyWith(color: AppTheme.whiteColor),
          ),
        ],
      ),
    );
  }
}
