import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PolicyScreenIOS extends StatelessWidget {
  const PolicyScreenIOS({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Privacy Policy'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 8),

            // Card container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground.resolveFrom(context),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Privacy Policy (Demo)',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 12),

                  Text(
                    'This app is currently under development and used for demo purposes only.',
                    style: TextStyle(fontSize: 15, height: 1.5),
                  ),

                  SizedBox(height: 16),

                  _Section(
                    title: '1. Data Collection',
                    content:
                        'We do not collect any personal data in this demo version.',
                  ),
                  _Section(
                    title: '2. Usage',
                    content:
                        'This application is for testing and demonstration purposes only.',
                  ),
                  _Section(
                    title: '3. Security',
                    content: 'No real user data is stored or processed.',
                  ),
                  _Section(
                    title: '4. Changes',
                    content: 'This policy may change in future versions.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Footer
            Center(
              child: Text(
                'Last updated: 2026',
                style: TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String content;

  const _Section({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(content, style: const TextStyle(fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}
