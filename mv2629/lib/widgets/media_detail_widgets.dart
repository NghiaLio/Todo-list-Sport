import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mv2629/constants/theme.dart';
import 'package:mv2629/utils/image_helper.dart';
import 'package:mv2629/views/skeleton/image_skeleton.dart';
import 'package:mv2629/widgets/button_arrow.dart';
import 'package:readmore/readmore.dart';
import 'package:responsive_builder/responsive_builder.dart';

class MediaDetailViewModel {
  final String name;
  final String dateText;
  final String overview;
  final String? posterPath;
  final String? keyVideo;
  final int episodeRuntime;
  final int totalRuntime;
  final int totalEpisodes;
  final String originalLanguage;
  final String genres;

  const MediaDetailViewModel({
    required this.name,
    required this.dateText,
    required this.overview,
    this.posterPath,
    this.keyVideo,
    required this.episodeRuntime,
    required this.totalRuntime,
    required this.totalEpisodes,
    required this.originalLanguage,
    required this.genres,
  });
}

class MediaPosterItem {
  final int id;
  final String? posterPath;

  const MediaPosterItem({required this.id, this.posterPath});
}

class MediaDetailContent extends StatelessWidget {
  const MediaDetailContent({
    super.key,
    required this.model,
    required this.similarItems,
    required this.isLoadingMore,
    required this.similarScrollController,
    required this.onBack,
    required this.onPlayTrailer,
    required this.onTapSimilar,
    this.mainTitle = 'Overview',
    this.moreLikeTitle = 'More Like This',
  });

  final MediaDetailViewModel model;
  final List<MediaPosterItem> similarItems;
  final bool isLoadingMore;
  final ScrollController similarScrollController;
  final VoidCallback onBack;
  final VoidCallback onPlayTrailer;
  final ValueChanged<int> onTapSimilar;
  final String mainTitle;
  final String moreLikeTitle;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ButtonArrow(onPressed: onBack, size: 40),
          _buildPosterWithPlay(context),
          const SizedBox(height: 12),
          _buildHeaderInfo(context),
          const SizedBox(height: 1),
          if (model.keyVideo != null) _buildTrailerButton(context),
          const SizedBox(height: 32),
          _buildOverviewSection(context),
          const SizedBox(height: 12),
          if (similarItems.isNotEmpty) _buildSimilarSection(context),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPosterWithPlay(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Container(
              width: getValueForScreenType<double>(
                context: context,
                mobile:
                    MediaQuery.of(context).orientation == Orientation.portrait
                    ? MediaQuery.of(context).size.width * 0.65
                    : MediaQuery.of(context).size.width * 0.45,
                tablet:
                    MediaQuery.of(context).orientation == Orientation.portrait
                    ? MediaQuery.of(context).size.width * 0.55
                    : MediaQuery.of(context).size.width * 0.45,
                desktop: MediaQuery.of(context).size.width * 0.35,
              ),
              height: getValueForScreenType<double>(
                context: context,
                mobile:
                    MediaQuery.of(context).orientation == Orientation.portrait
                    ? MediaQuery.of(context).size.height * 0.4
                    : MediaQuery.of(context).size.height * 0.5,
                tablet:
                    MediaQuery.of(context).orientation == Orientation.portrait
                    ? MediaQuery.of(context).size.height * 0.35
                    : MediaQuery.of(context).size.height * 0.5,
                desktop: MediaQuery.of(context).size.height * 0.6,
              ),
              color: AppTheme.placeholderDarkColor,
              child: model.posterPath != null
                  ? CachedNetworkImage(
                      imageUrl: ImageHelper.getImageUrl(model.posterPath!),
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const ImageSkeleton(borderRadius: 16),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error, color: AppTheme.greyColor),
                    )
                  : const Icon(
                      Icons.image_not_supported,
                      size: 64,
                      color: AppTheme.greyColor,
                    ),
            ),
            if (model.keyVideo != null)
              Positioned(
                bottom: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black26,
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
    );
  }

  Widget _buildHeaderInfo(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                model.name,
                style: Theme.of(
                  context,
                ).textTheme.displayMedium?.copyWith(fontSize: 26),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                model.dateText,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 22,
                  color: AppTheme.grey400Color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrailerButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: onPlayTrailer,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          minimumSize: Size(
            getValueForScreenType<double>(
              context: context,
              mobile: MediaQuery.of(context).orientation == Orientation.portrait
                  ? MediaQuery.of(context).size.width * 0.65
                  : MediaQuery.of(context).size.width * 0.45,
              tablet: MediaQuery.of(context).orientation == Orientation.portrait
                  ? MediaQuery.of(context).size.width * 0.55
                  : MediaQuery.of(context).size.width * 0.45,
              desktop: MediaQuery.of(context).size.width * 0.35,
            ),
            48,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          'Play Trailer',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.whiteColor,
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          mainTitle,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.grey600Color,
          ),
        ),
        const SizedBox(height: 8),
        _InfoRowWidget(
          title: 'RUNTIME',
          content: '${model.episodeRuntime} Minutes',
        ),
        _InfoRowWidget(
          title: 'TOTAL RUNTIME',
          content:
              '${model.totalRuntime} Minutes — ${model.totalEpisodes} Episodes',
        ),
        _InfoRowWidget(
          title: 'LANGUAGES',
          content: model.originalLanguage.toUpperCase(),
        ),
        _InfoRowWidget(
          title: 'GENRES',
          content: model.genres.isEmpty ? 'N/A' : model.genres,
        ),
        _InfoRowWidget(
          title: 'OVERVIEW',
          content: model.overview.isEmpty
              ? 'No overview available.'
              : model.overview,
          isReadMore: true,
        ),
      ],
    );
  }

  Widget _buildSimilarSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          moreLikeTitle,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.grey600Color,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: getValueForScreenType<double>(
            context: context,
            mobile: MediaQuery.of(context).orientation == Orientation.portrait
                ? MediaQuery.of(context).size.height * 0.25
                : MediaQuery.of(context).size.height * 0.35,
            tablet: MediaQuery.of(context).orientation == Orientation.portrait
                ? MediaQuery.of(context).size.height * 0.2
                : MediaQuery.of(context).size.height * 0.35,
            desktop: MediaQuery.of(context).size.height * 0.45,
          ),
          child: ListView.builder(
            controller: similarScrollController,
            scrollDirection: Axis.horizontal,
            itemCount: similarItems.length + (isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= similarItems.length) {
                return _buildSimilarLoadingIndicator();
              }
              final item = similarItems[index];
              final imageUrl = ImageHelper.getImageUrl(item.posterPath ?? '');
              return GestureDetector(
                onTap: () => onTapSimilar(item.id),
                child: Container(
                  width: getValueForScreenType<double>(
                    context: context,
                    mobile:
                        MediaQuery.of(context).orientation ==
                            Orientation.portrait
                        ? MediaQuery.of(context).size.width * 0.33
                        : MediaQuery.of(context).size.width * 0.2,
                    tablet:
                        MediaQuery.of(context).orientation ==
                            Orientation.portrait
                        ? MediaQuery.of(context).size.width * 0.25
                        : MediaQuery.of(context).size.width * 0.2,
                    desktop: MediaQuery.of(context).size.width * 0.15,
                  ),
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.placeholderDarkColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: item.posterPath != null
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                const ImageSkeleton(),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.error,
                              color: AppTheme.greyColor,
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: AppTheme.greyColor,
                              size: 32,
                            ),
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSimilarLoadingIndicator() {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppTheme.placeholderDarkColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryColor,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class _InfoRowWidget extends StatelessWidget {
  const _InfoRowWidget({
    required this.title,
    required this.content,
    this.isReadMore = false,
  });

  final String title;
  final String content;
  final bool isReadMore;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 11,
            color: AppTheme.grey400Color,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        DefaultTextStyle(
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: AppTheme.grey700Color,
            fontWeight: FontWeight.w500,
          ),
          child: isReadMore
              ? ReadMoreText(
                  content,
                  trimLines: 3,
                  colorClickableText: AppTheme.primaryColor,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: 'Show more',
                  trimExpandedText: 'Show less',
                  moreStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                  lessStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                )
              : Text(content),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 4.0),
          child: Divider(color: AppTheme.dividerSoftColor, thickness: 1),
        ),
      ],
    );
  }
}
