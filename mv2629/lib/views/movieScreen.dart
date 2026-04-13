// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/movies/movieCubit.dart';
import '../bloc/movies/movieState.dart';
import '../constants/theme.dart';
import '../models/filterMovie.dart';
import '../models/movie.dart';
import '../models/taskSportCard.dart';
import '../utils/image_helper.dart';
import '../views/movieScreenDetail.dart';
import '../views/skeleton/image_skeleton.dart';
import '../views/skeleton/tv_show_card_skeleton.dart';
import '../widgets/custom_header.dart';
import '../widgets/media_screen_widgets.dart';
import '../widgets/showSnackBar.dart';
import 'package:responsive_builder/responsive_builder.dart';

class MovieScreen extends StatefulWidget {
  const MovieScreen({super.key});

  @override
  State<MovieScreen> createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    context.read<MovieCubit>().init();
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
        context.read<MovieCubit>().clearSearch();
      } else {
        context.read<MovieCubit>().search(value.trim());
      }
    });
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) {
      context.read<MovieCubit>().loadMore();
    }
  }

  void _openFilterSheet(FilterMovie current) {
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
          context.read<MovieCubit>().updateFilter(
                FilterMovie(
                  minRating: newFilter.minRating,
                  maxRating: newFilter.maxRating,
                  fromYear: newFilter.fromYear,
                  toYear: newFilter.toYear,
                  sportType: newFilter.sportType,
                  sportKeyword: newFilter.sportKeyword,
                ),
              );
        },
        onClear: () => context.read<MovieCubit>().clearFilter(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.whiteColor,
      appBar: buildAppBar(context, 'Movies'),
      body: Column(
        children: [
          BlocBuilder<MovieCubit, MovieState>(
            buildWhen: (prev, curr) {
              if (curr is MovieLoaded && prev is MovieLoaded) {
                return curr.activeFilter != prev.activeFilter;
              }
              return false;
            },
            builder: (context, state) {
              final activeFilter =
                  state is MovieLoaded ? state.activeFilter : const FilterMovie();
              return MediaSearchAndFilterBar(
                controller: _searchController,
                onChanged: _onSearchChanged,
                hintText: 'Search movies...',
                hasActiveFilter: !activeFilter.isEmpty,
                onFilterTap: () => _openFilterSheet(activeFilter),
              );
            },
          ),
          BlocBuilder<MovieCubit, MovieState>(
            buildWhen: (prev, curr) =>
                (curr is MovieLoaded) &&
                (prev is! MovieLoaded ||
                    (prev).activeFilter != (curr).activeFilter),
            builder: (context, state) {
              if (state is! MovieLoaded || state.activeFilter.isEmpty) {
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
                onClear: () => context.read<MovieCubit>().clearFilter(),
                sportLabel: _sportLabel,
              );
            },
          ),
          Expanded(
            child: BlocConsumer<MovieCubit, MovieState>(
              listenWhen: (_, curr) => curr is MovieError,
              listener: (context, state) {
                if (state is MovieError) {
                  ShowSnackBar.show(
                    context,
                    message: state.message,
                    type: SnackBarType.error,
                  );
                }
              },
              builder: (context, state) {
                if (state is MovieLoading || state is MovieInitial) {
                  return _buildGrid(const [], showSkeleton: true);
                }
                if (state is MovieLoaded) {
                  return _buildGrid(
                    state.movies,
                    showSkeleton: false,
                    isLoadingMore: state.isLoadingMore,
                  );
                }
                if (state is MovieError) {
                  return MediaErrorView(
                    message: state.message,
                    onRetry: () => context.read<MovieCubit>().init(),
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
    List<Movie> movies, {
    required bool showSkeleton,
    bool isLoadingMore = false,
  }) {
    return MediaGridWidget<Movie>(
      items: movies,
      showSkeleton: showSkeleton,
      isLoadingMore: isLoadingMore,
      scrollController: _scrollController,
      itemBuilder: (context, movie) => _MovieCard(movie: movie),
      skeletonBuilder: (_) => const TvShowCardSkeleton(),
      emptyView: const MediaEmptyView(
        icon: Icons.movie_filter_outlined,
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

class _MovieCard extends StatelessWidget {
  const _MovieCard({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final imageUrl = ImageHelper.getImageUrl(movie.posterPath);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MovieScreenDetail(movieId: movie.id)),
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
                      : const Icon(Icons.movie),
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
                      movie.name,
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
                          movie.voteAverage.toStringAsFixed(1),
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
                          (movie.releaseDate != null && movie.releaseDate!.length >= 4)
                              ? movie.releaseDate!.substring(0, 4)
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
