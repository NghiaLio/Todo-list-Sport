import 'package:flutter/material.dart';
import 'package:mv2629/constants/theme.dart';
import 'package:mv2629/models/tvPreviewModels.dart';
import 'package:mv2629/views/tvShowDetail.dart';
import 'package:mv2629/views/skeleton/tv_show_card_skeleton.dart';
import 'package:mv2629/widgets/custom_header.dart';

class Tvscreen extends StatefulWidget {
  const Tvscreen({super.key});

  @override
  State<Tvscreen> createState() => _TvscreenState();
}

class _TvscreenState extends State<Tvscreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading data
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  List<TvPreviewModel> tvShows = [
    TvPreviewModel(
      title: 'Stranger Things',
      releaseDate: '2016-07-15',
      imdbRating: 8.7,
    ),
    TvPreviewModel(
      title: 'Breaking Bad',
      releaseDate: '2008-01-20',
      imdbRating: 9.5,
    ),
    TvPreviewModel(
      title: 'Game of Thrones',
      releaseDate: '2011-04-17',
      imdbRating: 9.3,
    ),
    TvPreviewModel(
      title: 'Breaking Bad',
      releaseDate: '2008-01-20',
      imdbRating: 9.5,
    ),
    TvPreviewModel(
      title: 'Game of Thrones',
      releaseDate: '2011-04-17',
      imdbRating: 9.3,
    ),
    TvPreviewModel(
      title: 'Breaking Bad',
      releaseDate: '2008-01-20',
      imdbRating: 9.5,
    ),
    TvPreviewModel(
      title: 'Game of Thrones',
      releaseDate: '2011-04-17',
      imdbRating: 9.3,
    ),
    TvPreviewModel(
      title: 'Breaking Bad',
      releaseDate: '2008-01-20',
      imdbRating: 9.5,
    ),
    TvPreviewModel(
      title: 'Game of Thrones',
      releaseDate: '2011-04-17',
      imdbRating: 9.3,
    ),
    TvPreviewModel(
      title: 'Breaking Bad',
      releaseDate: '2008-01-20',
      imdbRating: 9.5,
    ),
    TvPreviewModel(
      title: 'Game of Thrones',
      releaseDate: '2011-04-17',
      imdbRating: 9.3,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.whiteColor,
      appBar: buildAppBar(context, 'TV Shows'),
      body: Column(
        children: [
          // Search & Filter Bar
          const _SearchAndFilterBar(),
          // Grid View
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 columns
                  childAspectRatio: 0.55, // Aspect ratio to fit image and text
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                ),
                itemCount: isLoading
                    ? 6
                    : tvShows.length, // Show 6 skeletons while loading
                itemBuilder: (context, index) {
                  if (isLoading) {
                    return const TvShowCardSkeleton();
                  }
                  return _buildTvShowCard(tvShows[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTvShowCard(TvPreviewModel show) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TvShowDetail()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.whiteColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: AppTheme.black10Color,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Poster Image Placeholder (Top Part)
              Expanded(
                child: Container(
                  color: AppTheme.placeholderDarkColor, // Dark grey placeholder
                  child: Image.asset(show.imageUrl, fit: BoxFit.cover),
                ),
              ),
              // Info Banner (Bottom Part)
              Container(
                color:
                    AppTheme.primaryColor, // Light blue color from UI matching
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 10.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      show.title,
                      style: const TextStyle(
                        color: AppTheme.whiteColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        fontFamily: '',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Rating Block
                        SizedBox(
                          child: Text(
                            'IMDb: ${show.imdbRating}',
                            style: const TextStyle(
                              color: AppTheme.whiteColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              fontFamily: '',
                            ),
                          ),
                        ),

                        const Spacer(),
                        // Duration Block Mock
                        const Icon(
                          Icons.access_time,
                          color: AppTheme.primaryColor,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '2h 20m', // Hardcoded since the mock doesn't have duration
                          style: TextStyle(
                            color: AppTheme.whiteColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            fontFamily: '',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchAndFilterBar extends StatelessWidget {
  const _SearchAndFilterBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.whiteColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppTheme.cardBorderColor,
                  width: 1.2,
                ), // match app theme tone
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search TV shows...',
                  hintStyle: TextStyle(color: AppTheme.greyColor, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: AppTheme.greyColor),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.tune, color: AppTheme.whiteColor),
              onPressed: () {
                // Filter action placeholder
              },
            ),
          ),
        ],
      ),
    );
  }
}
