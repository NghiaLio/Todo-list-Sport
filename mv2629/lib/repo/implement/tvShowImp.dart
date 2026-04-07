import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mv2629/models/filterTvShow.dart';
import 'package:mv2629/models/taskSportCard.dart';
import 'package:mv2629/models/tvShow.dart';
import 'package:mv2629/repo/dioClient.dart';
import 'package:mv2629/repo/tvShowRepo.dart';

class TvShowService implements TvShowRepo {
  final ApiService dio;
  final String discoveryUrl;
  final String searchUrl;

  TvShowService({
    ApiService? apiService,
    String? discoveryUrl,
    String? searchUrl,
  })  : dio = apiService ?? ApiService(),
        discoveryUrl = discoveryUrl ?? dotenv.env['BASE_URL_DISCOVERY'] ?? "",
        searchUrl = searchUrl ?? dotenv.env['BASE_URL_SEARCH'] ?? "";

  @override
  Future<List<TvShow>?> discoverTv(int page) async {
    try {
      final res = await dio.get(
        discoveryUrl,
        queryParameters: {'with_genres': '99,10764', 'page': page},
      );

      return (res.data['results'] as List)
          .map((e) => TvShow.fromJson(e))
          .toList();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<TvShow>?> searchTv(String query, int page) async {
    try {
      final res = await dio.get(
        searchUrl,
        queryParameters: {'query': query, 'page': page},
      );

      return (res.data['results'] as List)
          .map((e) => TvShow.fromJson(e))
          .toList();
    } catch (e) {
      return null;
    }
  }

  @override
  double sportScore(TvShow tv) {
    double score = 0;
    final text = (tv.name + tv.overview).toLowerCase();

    if (text.contains('sport')) score += 3;
    if (text.contains('football')) score += 3;
    if (text.contains('basketball')) score += 3;
    if (text.contains('esport')) score += 2;

    if (tv.genreIds.contains(99)) score += 1.5;
    if (tv.genreIds.contains(10764)) score += 1.5;

    return score;
  }

  bool isSport(TvShow tv) => sportScore(tv) >= 3;

  @override
  List<TvShow> applyFilter(List<TvShow> list, FilterTvShow f) {
    return list.where((tv) {
      // ── Rating ──
      if (f.minRating != null && tv.voteAverage < f.minRating!) return false;
      if (f.maxRating != null && tv.voteAverage > f.maxRating!) return false;

      // ── Year ── (null-safe: skip items without a valid date)
      if (f.fromYear != null || f.toYear != null) {
        final rawDate = tv.firstAirDate;
        if (rawDate == null || rawDate.length < 4) {
          // Can't determine year → exclude when year filter is active
          return false;
        }
        final year = int.tryParse(rawDate.substring(0, 4));
        if (year == null) return false;
        if (f.fromYear != null && year < f.fromYear!) return false;
        if (f.toYear != null && year > f.toYear!) return false;
      }

      // ── Sport keyword (free-text) ──
      if (f.sportKeyword != null && f.sportKeyword!.trim().isNotEmpty) {
        final needle = f.sportKeyword!.trim().toLowerCase();
        final haystack = '${tv.name} ${tv.overview}'.toLowerCase();
        if (!haystack.contains(needle)) return false;
      }

      // ── Sport type (enum-based) ──
      if (f.sportType != null && !matchSportType(tv, f.sportType!)) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  bool matchSportType(TvShow tv, SportType type) {
    final text = '${tv.name} ${tv.overview}'.toLowerCase();

    switch (type) {
      case SportType.football:
        return text.contains('football') || text.contains('soccer');
      case SportType.basketball:
        return text.contains('basketball');
      case SportType.golf:
        return text.contains('golf');
      case SportType.rugby:
        return text.contains('rugby');
      case SportType.volleyball:
        return text.contains('volleyball');
    }
  }
}