// ignore_for_file: file_names

import '../models/filterTvShow.dart';
import '../models/taskSportCard.dart';
import '../models/tvShow.dart';

abstract class TvShowRepo {
  Future<List<TvShow>?> discoverTv(int page);
  Future<List<TvShow>?> searchTv(String query, int page);
  double sportScore(TvShow tv);
  List<TvShow> applyFilter(List<TvShow> list, FilterTvShow f);
  bool matchSportType(TvShow tv, SportType type);
}
