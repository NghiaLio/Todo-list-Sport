import '../../constants/app_config.dart';
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
       baseUrlImage = baseUrlImage ?? AppConfig.baseUrlImage,
       baseUrlTvShowDetail =
           baseUrlTvShowDetail ?? AppConfig.baseUrlGetTvDetail,
       baseUrlTvShowSimilar =
           baseUrlTvShowSimilar ?? AppConfig.baseUrlGetTvSimilar,
       baseUrlTvShowVideoTrailer =
           baseUrlTvShowVideoTrailer ?? AppConfig.baseUrlGetTvVideoTrailer;

  @override
  Future<TvDetail?> getTvShowDetail(int id) async {
    final res = await dio.get(
      baseUrlTvShowDetail.replaceAll('{series_id}', id.toString()),
    );
    return TvDetail.fromJson(res.data);
  }

  @override
  Future<List<TvShow>?> getSimilarTvShows(int id, int page) async {
    final res = await dio.get(
      baseUrlTvShowSimilar.replaceAll('{series_id}', id.toString()),
      queryParameters: {'page': page},
    );
    return (res.data['results'] as List)
        .map((e) => TvShow.fromJson(e))
        .toList();
  }

  @override
  Future<String?> getTvShowVideoTrailer(int id) async {
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
  }
}
