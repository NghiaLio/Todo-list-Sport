import 'package:equatable/equatable.dart';
import '../../models/movie.dart';
import '../../models/movieDetailModel.dart';

abstract class MovieDetailState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MovieDetailInitial extends MovieDetailState {}

class MovieDetailLoading extends MovieDetailState {}

class MovieDetailLoaded extends MovieDetailState {
  final MovieDetail movieDetail;
  final List<Movie> similarMovies;

  MovieDetailLoaded({required this.movieDetail, required this.similarMovies});

  MovieDetailLoaded copyWith({
    MovieDetail? movieDetail,
    List<Movie>? similarMovies,
  }) {
    return MovieDetailLoaded(
      movieDetail: movieDetail ?? this.movieDetail,
      similarMovies: similarMovies ?? this.similarMovies,
    );
  }

  @override
  List<Object?> get props => [movieDetail, similarMovies];
}

class MovieDetailError extends MovieDetailState {
  final String message;

  MovieDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
