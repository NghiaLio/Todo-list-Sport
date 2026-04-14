import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String _value(String key, [String fallback = '']) {
    return dotenv.env[key] ?? fallback;
  }

  static String get apiBaseUrl => _value('URL_DB');
  static String get apiKey => _value('API_KEY');

  static String get baseUrlImage => _value('BASE_URL_IMAGE');
  static String get baseUrlSearchMovie => _value('BASE_URL_SEARCH_MOVIE');
  static String get baseUrlSearchTv => _value('BASE_URL_SEARCH_TV');

  static String get baseUrlGetMovieDetail =>
      _value('BASE_URL_GET_MOVIE_DETAIL');
  static String get baseUrlGetMovieSimilar =>
      _value('BASE_URL_GET_MOVIE_SIMILAR');
  static String get baseUrlGetMovieVideoTrailer =>
      _value('BASE_URL_GET_MOVIE_VIDEO_TRAILER');

  static String get baseUrlGetTvDetail => _value('BASE_URL_GET_TV_DETAIL');
  static String get baseUrlGetTvSimilar => _value('BASE_URL_GET_TV_SIMILAR');
  static String get baseUrlGetTvVideoTrailer =>
      _value('BASE_URL_GET_VIDEO_TRAILER');

  static String get baseUrlYoutube =>
      _value('BASE_URL_YOUTUBE', 'https://www.youtube.com/watch?v=');
}
