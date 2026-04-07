// d:\Lasbom-Dev\Project-dev\mv2629\lib\bloc\tvShows\tvShowState.dart

import 'package:mv2629/models/filterTvShow.dart';
import 'package:mv2629/models/tvShow.dart';

abstract class TvShowState {}

class TvShowInitial extends TvShowState {}

class TvShowLoading extends TvShowState {}

/// Data is available; optionally still fetching more pages.
class TvShowLoaded extends TvShowState {
  final List<TvShow> tvShows;
  final FilterTvShow activeFilter;
  final bool isLoadingMore;
  final bool hasReachedMax;

  TvShowLoaded({
    required this.tvShows,
    required this.activeFilter,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
  });

  TvShowLoaded copyWith({
    List<TvShow>? tvShows,
    FilterTvShow? activeFilter,
    bool? isLoadingMore,
    bool? hasReachedMax,
  }) {
    return TvShowLoaded(
      tvShows: tvShows ?? this.tvShows,
      activeFilter: activeFilter ?? this.activeFilter,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class TvShowError extends TvShowState {
  final String message;
  TvShowError({required this.message});
}
