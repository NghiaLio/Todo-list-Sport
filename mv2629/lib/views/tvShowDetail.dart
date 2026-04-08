import 'package:cached_network_image/cached_network_image.dart';
import 'package:mv2629/widgets/button_arrow.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:readmore/readmore.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mv2629/bloc/tvShowDetail/tvShowDetailCubit.dart';
import 'package:mv2629/bloc/tvShowDetail/tvShowDetailState.dart';
import 'package:mv2629/constants/theme.dart';
import 'package:mv2629/models/tvShowDetailModel.dart';
import 'package:mv2629/utils/image_helper.dart';
import 'package:mv2629/views/skeleton/image_skeleton.dart';
import 'package:mv2629/views/skeleton/tv_show_detail_skeleton.dart';

class TvShowDetail extends StatelessWidget {
  final int tvShowId;
  const TvShowDetail({super.key, required this.tvShowId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TvShowDetailCubit()..getTvShowDetail(tvShowId),
      child: _TvShowDetailView(tvShowId: tvShowId),
    );
  }
}

class _TvShowDetailView extends StatefulWidget {
  final int tvShowId;
  const _TvShowDetailView({required this.tvShowId});

  @override
  State<_TvShowDetailView> createState() => __TvShowDetailViewState();
}

class __TvShowDetailViewState extends State<_TvShowDetailView> {
  final ScrollController _similarScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _similarScrollController.addListener(_onSimilarScroll);
  }

  @override
  void dispose() {
    _similarScrollController.dispose();
    super.dispose();
  }

  void _onSimilarScroll() {
    if (_similarScrollController.position.pixels >=
        _similarScrollController.position.maxScrollExtent - 200) {
      context.read<TvShowDetailCubit>().loadMoreSimilar(widget.tvShowId);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  //  Action Methods (Logic separated from UI)
  // ─────────────────────────────────────────────────────────────────────────────

  void _onRetry(BuildContext context) {
    context.read<TvShowDetailCubit>().getTvShowDetail(widget.tvShowId);
  }

  void _onPlayTrailer() {
    // TODO: Implement video playback logic here
  }

  void _onTapSimilarShow(int showId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TvShowDetail(tvShowId: showId)),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  //  UI Builders
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.whiteColor,
      body: SafeArea(
        child: BlocBuilder<TvShowDetailCubit, TvShowDetailState>(
          buildWhen: (previous, current) {
            // Rebuild if state type changes
            if (previous.runtimeType != current.runtimeType) return true;
            // For Loaded state, only rebuild if the main TV detail changed
            if (previous is TvShowDetailLoaded &&
                current is TvShowDetailLoaded) {
              return previous.tvDetail != current.tvDetail;
            }
            return true;
          },
          builder: (context, state) {
            if (state is TvShowDetailLoading || state is TvShowDetailInitial) {
              return const TvShowDetailSkeleton();
            }

            if (state is TvShowDetailError) {
              return _buildErrorState(context, state.message);
            }

            if (state is TvShowDetailLoaded) {
              return _buildLoadedState(context, state);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Error: $message'),
          ElevatedButton(
            onPressed: () => _onRetry(context),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, TvShowDetailLoaded state) {
    final tv = state.tvDetail;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ButtonArrow(onPressed: () => Navigator.of(context).pop(), size: 40),
          _buildPosterWithPlay(context, tv),
          const SizedBox(height: 12),
          _buildHeaderInfo(tv),
          const SizedBox(height: 1),
          if (tv.keyVideo != null) _buildTrailerButton(context),
          const SizedBox(height: 32),
          _buildOverviewSection(tv),
          const SizedBox(height: 12),
          BlocBuilder<TvShowDetailCubit, TvShowDetailState>(
            buildWhen: (previous, current) =>
                current is TvShowDetailLoaded &&
                (previous is! TvShowDetailLoaded ||
                    previous.similarTvShows != current.similarTvShows ||
                    previous.isLoadingMore != current.isLoadingMore),
            builder: (context, state) {
              if (state is TvShowDetailLoaded &&
                  state.similarTvShows.isNotEmpty) {
                return _buildSimilarShowsSection(context, state);
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPosterWithPlay(BuildContext context, TvDetail tv) {
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
              child: tv.posterPath != null
                  ? CachedNetworkImage(
                      imageUrl: ImageHelper.getImageUrl(tv.posterPath!),
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
            if (tv.keyVideo != null)
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

  Widget _buildHeaderInfo(TvDetail tv) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                tv.name,
                style: Theme.of(
                  context,
                ).textTheme.displayMedium?.copyWith(fontSize: 26),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                tv.getFirstAirDate(),
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
        onPressed: _onPlayTrailer,
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

  Widget _buildOverviewSection(TvDetail tv) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.grey600Color,
          ),
        ),
        const SizedBox(height: 8),
        _InfoRowWidget(
          title: 'RUNTIME',
          content: '${tv.getEpisodeRuntime()} Minutes',
        ),
        _InfoRowWidget(
          title: 'TOTAL RUNTIME',
          content:
              '${tv.getTotalRuntime()} Minutes — ${tv.numberOfEpisodes} Episodes',
        ),
        _InfoRowWidget(
          title: 'LANGUAGES',
          content: tv.originalLanguage.toUpperCase(),
        ),
        _InfoRowWidget(title: 'GENRES', content: tv.getGenres()),
        _InfoRowWidget(
          title: 'OVERVIEW',
          content: tv.overview,
          isReadMore: true,
        ),
      ],
    );
  }

  Widget _buildSimilarShowsSection(
    BuildContext context,
    TvShowDetailLoaded state,
  ) {
    final similarTvShows = state.similarTvShows;
    final isLoadingMore = state.isLoadingMore;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'More Like This',
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
            controller: _similarScrollController,
            scrollDirection: Axis.horizontal,
            itemCount: similarTvShows.length + (isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= similarTvShows.length) {
                return _buildSimilarLoadingIndicator();
              }
              final similar = similarTvShows[index];
              final similarImageUrl = ImageHelper.getImageUrl(
                similar.posterPath ?? '',
              );
              return GestureDetector(
                onTap: () => _onTapSimilarShow(similar.id),
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
                    child: similar.posterPath != null
                        ? CachedNetworkImage(
                            imageUrl: similarImageUrl,
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
  final String title;
  final String content;
  final bool isReadMore;

  const _InfoRowWidget({
    required this.title,
    required this.content,
    this.isReadMore = false,
  });

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
