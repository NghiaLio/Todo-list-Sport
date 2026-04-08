import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:mv2629/constants/theme.dart';
import 'package:mv2629/widgets/custom_header.dart';

class Settingscreen extends StatelessWidget {
  const Settingscreen({super.key});

  static const List<String> settingsOptions = ['Share', 'Rate App', 'Policy'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.dividerSoftColor,
      appBar: buildAppBar(context, 'Settings'),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: getValueForScreenType<double>(
              context: context,
              mobile: MediaQuery.of(context).size.width * 0.8,
              tablet: MediaQuery.of(context).size.width * 0.5,
              desktop: MediaQuery.of(context).size.width * 0.3,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: settingsOptions
                .map(
                  (option) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _SettingsOptionWidget(
                      title: option,
                      onTap: () {
                        // Handle option tap
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _SettingsOptionWidget extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _SettingsOptionWidget({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: getValueForScreenType<double>(
          context: context,
          mobile: 56,
          tablet: 64,
          desktop: 64,
        ),
        width: double.infinity,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppTheme.blackColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
