// ignore_for_file: file_names

import 'package:mv2629/models/filterMovie.dart';
import 'package:mv2629/models/taskSportCard.dart';
import 'package:mv2629/models/movie.dart';

abstract class MovieRepo {
  Future<List<Movie>?> discoverMovie(int page);
  Future<List<Movie>?> searchMovie(String query, int page);
  double sportScore(Movie tv);
  List<Movie> applyFilter(List<Movie> list, FilterMovie f);
  bool matchSportType(Movie tv, SportType type);
}
