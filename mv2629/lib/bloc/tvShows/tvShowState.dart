import 'package:equatable/equatable.dart';
import '../../models/filterTvShow.dart';
import '../../models/tvShow.dart';

abstract class TvShowState extends Equatable {
  @override
  List<Object?> get props => [];
}

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

  @override
  List<Object?> get props => [
    tvShows,
    activeFilter,
    isLoadingMore,
    hasReachedMax,
  ];
}

class TvShowError extends TvShowState {
  final String message;
  TvShowError({required this.message});

  @override
  List<Object?> get props => [message];
}
