import 'package:equatable/equatable.dart';
import 'package:mv2629/models/movie.dart';
import 'package:mv2629/models/movieDetailModel.dart';

abstract class MovieDetailState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MovieDetailInitial extends MovieDetailState {}

class MovieDetailLoading extends MovieDetailState {}

class MovieDetailLoaded extends MovieDetailState {
  final MovieDetail movieDetail;
  final List<Movie> similarMovies;
  final bool isLoadingMore;
  final bool hasReachedMax;

  MovieDetailLoaded({
    required this.movieDetail,
    required this.similarMovies,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
  });

  MovieDetailLoaded copyWith({
    MovieDetail? movieDetail,
    List<Movie>? similarMovies,
    bool? isLoadingMore,
    bool? hasReachedMax,
  }) {
    return MovieDetailLoaded(
      movieDetail: movieDetail ?? this.movieDetail,
      similarMovies: similarMovies ?? this.similarMovies,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [
    movieDetail,
    similarMovies,
    isLoadingMore,
    hasReachedMax,
  ];
}

class MovieDetailError extends MovieDetailState {
  final String message;

  MovieDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
