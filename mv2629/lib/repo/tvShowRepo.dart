// ignore_for_file: file_names

import 'package:mv2629/models/filterTvShow.dart';
import 'package:mv2629/models/taskSportCard.dart';
import 'package:mv2629/models/tvShow.dart';

abstract class TvShowRepo{
  Future<List<TvShow>?> discoverTv(int page);
  Future<List<TvShow>?> searchTv(String query, int page);
  double sportScore(TvShow tv);
  List<TvShow> applyFilter(List<TvShow> list, FilterTvShow f);
  bool matchSportType(TvShow tv, SportType type);
}