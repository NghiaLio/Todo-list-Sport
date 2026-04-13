// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/tvShows/tvShowCubit.dart';
import '../bloc/tvShows/tvShowState.dart';
import '../constants/theme.dart';
import '../models/filterTvShow.dart';
import '../models/taskSportCard.dart';
import '../models/tvShow.dart';
import '../utils/image_helper.dart';
import '../views/skeleton/image_skeleton.dart';
import '../views/skeleton/tv_show_card_skeleton.dart';
import '../views/tvShowDetail.dart';
import '../widgets/custom_header.dart';
import '../widgets/media_screen_widgets.dart';
import '../widgets/showSnackBar.dart';
import 'package:responsive_builder/responsive_builder.dart';

class Tvscreen extends StatefulWidget {
  const Tvscreen({super.key});

  @override
  State<Tvscreen> createState() => _TvscreenState();
}

class _TvscreenState extends State<Tvscreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    context.read<TvShowCubit>().init();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (value.trim().isEmpty) {
        context.read<TvShowCubit>().clearSearch();
      } else {
        context.read<TvShowCubit>().search(value.trim());
      }
    });
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) {
      context.read<TvShowCubit>().loadMore();
    }
  }

  void _openFilterSheet(FilterTvShow current) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MediaFilterSheet(
        initialFilter: MediaFilterData(
          minRating: current.minRating,
          maxRating: current.maxRating,
          fromYear: current.fromYear,
          toYear: current.toYear,
          sportType: current.sportType,
          sportKeyword: current.sportKeyword,
        ),
        onApply: (newFilter) {
          context.read<TvShowCubit>().updateFilter(
                FilterTvShow(
                  minRating: newFilter.minRating,
                  maxRating: newFilter.maxRating,
                  fromYear: newFilter.fromYear,
                  toYear: newFilter.toYear,
                  sportType: newFilter.sportType,
                  sportKeyword: newFilter.sportKeyword,
                ),
              );
        },
        onClear: () => context.read<TvShowCubit>().clearFilter(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.whiteColor,
      appBar: buildAppBar(context, 'TV Shows'),
      body: Column(
        children: [
          BlocBuilder<TvShowCubit, TvShowState>(
            buildWhen: (prev, curr) {
              if (curr is TvShowLoaded && prev is TvShowLoaded) {
                return curr.activeFilter != prev.activeFilter;
              }
              return false;
            },
            builder: (context, state) {
              final activeFilter =
                  state is TvShowLoaded ? state.activeFilter : const FilterTvShow();
              return MediaSearchAndFilterBar(
                controller: _searchController,
                onChanged: _onSearchChanged,
                hintText: 'Search TV shows...',
                hasActiveFilter: !activeFilter.isEmpty,
                onFilterTap: () => _openFilterSheet(activeFilter),
              );
            },
          ),
          BlocBuilder<TvShowCubit, TvShowState>(
            buildWhen: (prev, curr) =>
                (curr is TvShowLoaded) &&
                (prev is! TvShowLoaded ||
                    (prev).activeFilter != (curr).activeFilter),
            builder: (context, state) {
              if (state is! TvShowLoaded || state.activeFilter.isEmpty) {
                return const SizedBox.shrink();
              }

              return MediaActiveFilterChips(
                filter: MediaFilterData(
                  minRating: state.activeFilter.minRating,
                  maxRating: state.activeFilter.maxRating,
                  fromYear: state.activeFilter.fromYear,
                  toYear: state.activeFilter.toYear,
                  sportType: state.activeFilter.sportType,
                  sportKeyword: state.activeFilter.sportKeyword,
                ),
                onClear: () => context.read<TvShowCubit>().clearFilter(),
                sportLabel: _sportLabel,
              );
            },
          ),
          Expanded(
            child: BlocConsumer<TvShowCubit, TvShowState>(
              listenWhen: (_, curr) => curr is TvShowError,
              listener: (context, state) {
                if (state is TvShowError) {
                  ShowSnackBar.show(
                    context,
                    message: state.message,
                    type: SnackBarType.error,
                  );
                }
              },
              builder: (context, state) {
                if (state is TvShowLoading || state is TvShowInitial) {
                  return _buildGrid(const [], showSkeleton: true);
                }
                if (state is TvShowLoaded) {
                  return _buildGrid(
                    state.tvShows,
                    showSkeleton: false,
                    isLoadingMore: state.isLoadingMore,
                  );
                }
                if (state is TvShowError) {
                  return MediaErrorView(
                    message: state.message,
                    onRetry: () => context.read<TvShowCubit>().init(),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(
    List<TvShow> shows, {
    required bool showSkeleton,
    bool isLoadingMore = false,
  }) {
    return MediaGridWidget<TvShow>(
      items: shows,
      showSkeleton: showSkeleton,
      isLoadingMore: isLoadingMore,
      scrollController: _scrollController,
      itemBuilder: (context, show) => _TvShowCard(show: show),
      skeletonBuilder: (_) => const TvShowCardSkeleton(),
      emptyView: const MediaEmptyView(
        icon: Icons.tv_off_rounded,
        title: 'No results found',
        subtitle: 'Try adjusting your filters or search keyword',
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: getValueForScreenType<int>(
          context: context,
          mobile: MediaQuery.of(context).orientation == Orientation.portrait ? 3 : 5,
          tablet: MediaQuery.of(context).orientation == Orientation.portrait ? 4 : 5,
          desktop: 6,
        ),
        childAspectRatio: getValueForScreenType<double>(
          context: context,
          mobile: MediaQuery.of(context).orientation == Orientation.portrait
              ? 0.55
              : 0.65,
          tablet: MediaQuery.of(context).orientation == Orientation.portrait
              ? 0.60
              : 0.7,
          desktop: 0.7,
        ),
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
    );
  }

  String _sportLabel(SportType t) {
    switch (t) {
      case SportType.football:
        return 'Football';
      case SportType.basketball:
        return 'Basketball';
      case SportType.volleyball:
        return 'Volleyball';
      case SportType.golf:
        return 'Golf';
      case SportType.rugby:
        return 'Rugby';
    }
  }
}

class _TvShowCard extends StatelessWidget {
  const _TvShowCard({required this.show});

  final TvShow show;

  @override
  Widget build(BuildContext context) {
    final imageUrl = ImageHelper.getImageUrl(show.posterPath);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TvShowDetail(tvShowId: show.id)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.whiteColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
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
              Expanded(
                child: Container(
                  color: AppTheme.placeholderDarkColor,
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => const ImageSkeleton(),
                          errorWidget: (_, _, _) => const Icon(Icons.broken_image),
                        )
                      : const Icon(Icons.tv),
                ),
              ),
              Container(
                color: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      show.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.whiteColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          show.voteAverage.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.whiteColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.calendar_today_rounded,
                          color: AppTheme.whiteColor,
                          size: 10,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          (show.firstAirDate != null && show.firstAirDate!.length >= 4)
                              ? show.firstAirDate!.substring(0, 4)
                              : 'N/A',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.whiteColor,
                            fontSize: 10,
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
