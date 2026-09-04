import '../../constants/app_config.dart';
import '../../models/movie.dart';
import '../../models/movieDetailModel.dart';
import '../../repo/dioClient.dart';
import '../../repo/movieDetailRepo.dart';

class MovieDetailService implements MovieDetailRepo {
  final ApiService dio;
  final String baseUrlImage;
  final String baseUrlMovieDetail;
  final String baseUrlMovieSimilar;
  final String baseUrlMovieVideoTrailer;

  MovieDetailService({
    ApiService? apiService,
    String? baseUrlImage,
    String? baseUrlMovieDetail,
    String? baseUrlMovieSimilar,
    String? baseUrlMovieVideoTrailer,
  }) : dio = apiService ?? ApiService(),
       baseUrlImage = baseUrlImage ?? AppConfig.baseUrlImage,
       baseUrlMovieDetail =
           baseUrlMovieDetail ?? AppConfig.baseUrlGetMovieDetail,
       baseUrlMovieSimilar =
           baseUrlMovieSimilar ?? AppConfig.baseUrlGetMovieSimilar,
       baseUrlMovieVideoTrailer =
           baseUrlMovieVideoTrailer ?? AppConfig.baseUrlGetMovieVideoTrailer;

  @override
  Future<MovieDetail?> getMovieDetail(int id) async {
    final res = await dio.get(
      baseUrlMovieDetail.replaceAll('{movie_id}', id.toString()),
    );
    return MovieDetail.fromJson(res.data);
  }

  @override
  Future<List<Movie>?> getSimilarMovies(int id, int page) async {
    final res = await dio.get(
      baseUrlMovieSimilar.replaceAll('{movie_id}', id.toString()),
      queryParameters: {'page': page},
    );
    return (res.data['results'] as List).map((e) => Movie.fromJson(e)).toList();
  }

  @override
  Future<String?> getMovieVideoTrailer(int id) async {
    final res = await dio.get(
      baseUrlMovieVideoTrailer.replaceAll('{movie_id}', id.toString()),
    );
    final results = res.data['results'] as List;
    if (results.isNotEmpty) {
      for (var video in results) {
        if (video['site'] == 'YouTube' && video['type'] == 'Trailer') {
          return video['key'];
        }
      }
    }
    return null;
  }
}
