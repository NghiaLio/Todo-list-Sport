// ignore_for_file: file_names

import '../models/filterMovie.dart';
import '../models/taskSportCard.dart';
import '../models/movie.dart';

abstract class MovieRepo {
  Future<List<Movie>?> discoverMovie(int page);
  Future<List<Movie>?> searchMovie(String query, int page);
  double sportScore(Movie tv);
  List<Movie> applyFilter(List<Movie> list, FilterMovie f);
  bool matchSportType(Movie tv, SportType type);
}
