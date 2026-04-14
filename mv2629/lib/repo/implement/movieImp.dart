import '../../constants/app_config.dart';
import '../../models/filterMovie.dart';
import '../../models/taskSportCard.dart';
import '../../models/movie.dart';
import '../../repo/dioClient.dart';
import '../../repo/movieRepo.dart';

class MovieService implements MovieRepo {
  final ApiService dio;
  final String searchUrl;

  MovieService({ApiService? apiService, String? searchUrl})
    : dio = apiService ?? ApiService(),
      searchUrl = searchUrl ?? AppConfig.baseUrlSearchMovie;

  @override
  Future<List<Movie>?> discoverMovie(int page) async {
    return searchMovie('sport', page);
  }

  @override
  Future<List<Movie>?> searchMovie(String query, int page) async {
    final res = await dio.get(
      searchUrl,
      queryParameters: {'query': query, 'page': page},
    );

    return (res.data['results'] as List).map((e) => Movie.fromJson(e)).toList();
  }

  @override
  double sportScore(Movie tv) {
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

  bool isSport(Movie tv) => sportScore(tv) >= 3;

  @override
  List<Movie> applyFilter(List<Movie> list, FilterMovie f) {
    return list.where((tv) {
      // ── Rating ──
      if (f.minRating != null && tv.voteAverage < f.minRating!) return false;
      if (f.maxRating != null && tv.voteAverage > f.maxRating!) return false;

      // ── Year ── (null-safe: skip items without a valid date)
      if (f.fromYear != null || f.toYear != null) {
        final rawDate = tv.releaseDate;
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
  bool matchSportType(Movie tv, SportType type) {
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
