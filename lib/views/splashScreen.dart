// ignore_for_file: use_build_context_synchronously, deprecated_member_use, file_names

import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../widgets/button_arrow.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  void _navigateToHome(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;
            final isSmallScreen = screenHeight < 700;
            final logoSize = (screenHeight * 0.32).clamp(160.0, 298.0);
            final spacing1 = isSmallScreen ? 16.0 : 36.0;
            final spacing2 = isSmallScreen ? 16.0 : 28.0;
            final bottomPadding = isSmallScreen ? 20.0 : 40.0;

            return SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                    minWidth: constraints.maxWidth,
                  ),
                  child: IntrinsicHeight(
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: bottomPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Spacer(),
                            _IllustrationWidget(size: logoSize),
                            SizedBox(height: spacing1),
                            const _TextContentWidget(),
                            SizedBox(height: spacing2),
                            ButtonArrow(
                              onPressed: () => _navigateToHome(context),
                              iconAsset: 'assets/rightArrow.png',
                              size: 69,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _IllustrationWidget extends StatelessWidget {
  final double size;
  const _IllustrationWidget({this.size = 298});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Image.asset(
        'assets/logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _TextContentWidget extends StatelessWidget {
  const _TextContentWidget();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
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
          const SizedBox(height: 16),
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
