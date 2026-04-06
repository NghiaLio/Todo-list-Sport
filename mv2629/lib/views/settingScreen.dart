import 'package:flutter/material.dart';
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
            maxWidth: MediaQuery.of(context).size.width * 0.5,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: settingsOptions
                .map(
                  (option) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildSettingsOption(context, option, () {
                      // Handle option tap
                    }),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsOption(
    BuildContext context,
    String title,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.08,
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
