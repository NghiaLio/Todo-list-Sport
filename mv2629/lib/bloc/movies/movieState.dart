import 'package:equatable/equatable.dart';
import '../../models/filterMovie.dart';
import '../../models/movie.dart';

abstract class MovieState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MovieInitial extends MovieState {}

class MovieLoading extends MovieState {}

/// Data is available; optionally still fetching more pages.
class MovieLoaded extends MovieState {
  final List<Movie> movies;
  final FilterMovie activeFilter;
  final bool isLoadingMore;
  final bool hasReachedMax;

  MovieLoaded({
    required this.movies,
    required this.activeFilter,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
  });

  MovieLoaded copyWith({
    List<Movie>? movies,
    FilterMovie? activeFilter,
    bool? isLoadingMore,
    bool? hasReachedMax,
  }) {
    return MovieLoaded(
      movies: movies ?? this.movies,
      activeFilter: activeFilter ?? this.activeFilter,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [
    movies,
    activeFilter,
    isLoadingMore,
    hasReachedMax,
  ];
}

class MovieError extends MovieState {
  final String message;
  MovieError({required this.message});

  @override
  List<Object?> get props => [message];
}
