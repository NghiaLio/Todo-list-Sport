import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/tvShow.dart';
import '../../models/tvShowDetailModel.dart';
import '../../repo/dioClient.dart';
import '../../repo/tvShowDetailRepo.dart';

class TvShowDetailService implements TvShowDetailRepo {
  final ApiService dio;
  final String baseUrlImage;
  final String baseUrlTvShowDetail;
  final String baseUrlTvShowSimilar;
  final String baseUrlTvShowVideoTrailer;

  TvShowDetailService({
    ApiService? apiService,
    String? baseUrlImage,
    String? baseUrlTvShowDetail,
    String? baseUrlTvShowSimilar,
    String? baseUrlTvShowVideoTrailer,
  }) : dio = apiService ?? ApiService(),
       baseUrlImage = baseUrlImage ?? dotenv.env['BASE_URL_IMAGE'] ?? "",
       baseUrlTvShowDetail =
           baseUrlTvShowDetail ?? dotenv.env['BASE_URL_GET_TV_DETAIL'] ?? "",
       baseUrlTvShowSimilar =
           baseUrlTvShowSimilar ?? dotenv.env['BASE_URL_GET_TV_SIMILAR'] ?? "",
       baseUrlTvShowVideoTrailer =
           baseUrlTvShowVideoTrailer ??
           dotenv.env['BASE_URL_GET_VIDEO_TRAILER'] ??
           "";

  @override
  Future<TvDetail?> getTvShowDetail(int id) async {
    try {
      final res = await dio.get(
        baseUrlTvShowDetail.replaceAll('{series_id}', id.toString()),
      );
      return TvDetail.fromJson(res.data);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<TvShow>?> getSimilarTvShows(int id, int page) async {
    try {
      final res = await dio.get(
        baseUrlTvShowSimilar.replaceAll('{series_id}', id.toString()),
        queryParameters: {'page': page},
      );
      return (res.data['results'] as List)
          .map((e) => TvShow.fromJson(e))
          .toList();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> getTvShowVideoTrailer(int id) async {
    try {
      final res = await dio.get(
        baseUrlTvShowVideoTrailer.replaceAll('{series_id}', id.toString()),
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
    } catch (e) {
      return null;
    }
  }
}
