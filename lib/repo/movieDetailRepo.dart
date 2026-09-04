import '../models/movie.dart';
import '../models/movieDetailModel.dart';

abstract class MovieDetailRepo {
  Future<MovieDetail?> getMovieDetail(int id);
  Future<List<Movie>?> getSimilarMovies(int id, int page);
  Future<String?> getMovieVideoTrailer(int id);
}
