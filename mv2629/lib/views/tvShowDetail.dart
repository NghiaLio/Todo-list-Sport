// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:mv2629/constants/theme.dart';
import 'package:mv2629/views/skeleton/tv_show_detail_skeleton.dart';

class TvShowDetail extends StatefulWidget {
  const TvShowDetail({super.key});

  @override
  State<TvShowDetail> createState() => _TvShowDetailState();
}

class _TvShowDetailState extends State<TvShowDetail> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading data for detail page.
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.whiteColor,
      body: SafeArea(
        child: isLoading
            ? const TvShowDetailSkeleton()
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Poster Image with Play Button
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.65,
                              height: MediaQuery.of(context).size.height * 0.4,
                              color: AppTheme
                                  .placeholderDarkColor, // Placeholder for image
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 64,
                                color: AppTheme.greyColor,
                              ),
                            ),
                            Positioned(
                              bottom: 16,
                              left: 16,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.white30Color,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow,
                                  color: AppTheme.whiteColor,
                                  size: 32,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 2. Title, Date, and Subtitle + Score
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'The Mandalorian',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.blackColor,
                                  fontFamily: '',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Nov 12, 2019',
                                style: TextStyle(
                                  fontSize: 22,
                                  color: AppTheme.grey400Color,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: '',
                                ),
                              ),
                              // const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),

                    // 3. Play Trailer Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          minimumSize: Size(
                            MediaQuery.of(context).size.width * 0.65,
                            48,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Play Trailer',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.whiteColor,
                                fontFamily: '',
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 4. Overview Section
                    Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.grey600Color,
                        fontFamily: '',
                      ),
                    ),
                    const SizedBox(height: 8),
                    _InfoRowWidget(title: 'RUNTIME', content: '37 Minutes'),
                    _InfoRowWidget(
                      title: 'TOTAL RUNTIME',
                      content: '9 Hours 15 Minutes — 15 Episodes',
                    ),
                    _InfoRowWidget(title: 'LANGUAGES', content: 'English'),
                    _InfoRowWidget(
                      title: 'GENRES',
                      content: '🚀 Science Fiction, 👽 Fantasy, 👊 Action, 🗺️ Adventure',
                    ),
                    _InfoRowWidget(title: 'OVERVIEW', content: 'content'),
                    const SizedBox(height: 12),

                    // 5. More Like This Section
                    Text(
                      'More Like This',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.grey600Color,
                        fontFamily: '',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.25,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          return Container(
                            width: MediaQuery.of(context).size.width * 0.33,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.placeholderDarkColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: AppTheme.greyColor,
                                size: 32,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
    );
  }

}

class _InfoRowWidget extends StatelessWidget {
  final String title;
  final String content;

  const _InfoRowWidget({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.grey400Color,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            fontFamily: '',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.grey700Color,
            fontWeight: FontWeight.w500,
            fontFamily: '',
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 4.0),
          child: Divider(color: AppTheme.dividerSoftColor, thickness: 1),
        ),
      ],
    );
  }
}
