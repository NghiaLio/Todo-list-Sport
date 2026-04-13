import 'package:flutter_dotenv/flutter_dotenv.dart';
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
       baseUrlImage = baseUrlImage ?? dotenv.env['BASE_URL_IMAGE'] ?? "",
       baseUrlMovieDetail =
           baseUrlMovieDetail ?? dotenv.env['BASE_URL_GET_MOVIE_DETAIL'] ?? "",
       baseUrlMovieSimilar =
           baseUrlMovieSimilar ??
           dotenv.env['BASE_URL_GET_MOVIE_SIMILAR'] ??
           "",
       baseUrlMovieVideoTrailer =
           baseUrlMovieVideoTrailer ??
           dotenv.env['BASE_URL_GET_VIDEO_TRAILER'] ??
           "";

  @override
  Future<MovieDetail?> getMovieDetail(int id) async {
    try {
      final res = await dio.get(
        baseUrlMovieDetail.replaceAll('{movie_id}', id.toString()),
      );
      return MovieDetail.fromJson(res.data);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Movie>?> getSimilarMovies(int id, int page) async {
    try {
      final res = await dio.get(
        baseUrlMovieSimilar.replaceAll('{movie_id}', id.toString()),
        queryParameters: {'page': page},
      );
      return (res.data['results'] as List)
          .map((e) => Movie.fromJson(e))
          .toList();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> getMovieVideoTrailer(int id) async {
    try {
      final res = await dio.get(
        baseUrlMovieVideoTrailer.replaceAll('{movie_id}', id.toString()),
      );
      final results = res.data['results'] as List;
      if (results.isNotEmpty) {
        return results[0]['key'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
