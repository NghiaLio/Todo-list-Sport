import 'package:mv2629/models/tvShow.dart';
import 'package:mv2629/models/tvShowDetailModel.dart';

abstract class TvShowDetailRepo {
  Future<TvDetail?> getTvShowDetail(int id);
  Future<List<TvShow>?> getSimilarTvShows(int id, int page);
  Future<String?> getTvShowVideoTrailer(int id);
}
