import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_config.dart';
import '../constants/theme.dart';
import '../widgets/custom_header.dart';
import 'package:share_plus/share_plus.dart';

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
                      onTap: () async {
                        if (option == 'Share') {
                          Share.share(
                            'Check out this amazing app: https://example.com/app',
                            subject: 'Amazing App',
                          );
                        } else if (option == 'Rate App') {
                          showRateDialog(context);
                        } else if (option == 'Policy') {
                          final uri = Uri.parse(AppConfig.policyUrl);
                          if (!await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          )) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Could not open policy'),
                                ),
                              );
                            }
                          }
                        }
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

void showRateDialog(BuildContext context) {
  showCupertinoDialog(
    context: context,
    builder: (_) => CupertinoAlertDialog(
      title: const Text('Enjoying the app?'),
      content: const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Text('Tap a star to rate it on the App Store.'),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () {
                Navigator.pop(context);
                // fake action
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  CupertinoIcons.star_fill,
                  color: CupertinoColors.systemYellow,
                ),
              ),
            );
          }),
        ),
        CupertinoDialogAction(
          child: const Text('Later'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}
