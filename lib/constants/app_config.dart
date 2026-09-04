class AppConfig {
  static const apiBaseUrl = 'https://api.themoviedb.org/3';
  static const apiKey = 'ca912b14f16546bedaa8fbac0babf439';
  static const apiToken =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJjYTkxMmIxNGYxNjU0NmJlZGFhOGZiYWMwYmFiZjQzOSIsIm5iZiI6MTczMDM0MzY3MC4xMjYwMDAyLCJzdWIiOiI2NzIyZjJmNjE4ODI3YTkzMjlmMTkzZTgiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.UnnVGBEjZFsKfwA_iqcBS1pl8IMBfYETyesVNy_ASdg';

  static const baseUrlImage = 'https://image.tmdb.org/t/p/w500';
  static const baseUrlSearchMovie = 'https://api.themoviedb.org/3/search/movie';
  static const baseUrlSearchTv = 'https://api.themoviedb.org/3/search/tv';

  static const baseUrlGetMovieDetail =
      'https://api.themoviedb.org/3/movie/{movie_id}';
  static const baseUrlGetMovieSimilar =
      'https://api.themoviedb.org/3/movie/{movie_id}/similar';
  static const baseUrlGetMovieVideoTrailer =
      'https://api.themoviedb.org/3/movie/{movie_id}/videos';

  static const baseUrlGetTvDetail =
      'https://api.themoviedb.org/3/tv/{series_id}';
  static const baseUrlGetTvSimilar =
      'https://api.themoviedb.org/3/tv/{series_id}/similar';
  static const baseUrlGetTvVideoTrailer =
      'https://api.themoviedb.org/3/tv/{series_id}/videos';

  static const baseUrlYoutube = 'https://www.youtube.com/watch?v=';

  static const policyUrl =
      'https://nghia-policy.web.app/apps/todo-list-sport/privacy-policy';
}
