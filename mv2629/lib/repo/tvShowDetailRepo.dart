import '../models/tvShow.dart';
import '../models/tvShowDetailModel.dart';

abstract class TvShowDetailRepo {
  Future<TvDetail?> getTvShowDetail(int id);
  Future<List<TvShow>?> getSimilarTvShows(int id, int page);
  Future<String?> getTvShowVideoTrailer(int id);
}
