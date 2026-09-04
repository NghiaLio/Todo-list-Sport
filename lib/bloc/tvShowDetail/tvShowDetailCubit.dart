import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/tvShowDetail/tvShowDetailState.dart';
import '../../models/tvShow.dart';
import '../../models/tvShowDetailModel.dart';
import '../../repo/implement/tvShowDetailImp.dart';
import '../../repo/tvShowDetailRepo.dart';

class TvShowDetailCubit extends Cubit<TvShowDetailState> {
  final TvShowDetailRepo tvShowDetailService;

  TvShowDetailCubit({TvShowDetailRepo? service})
    : tvShowDetailService = service ?? TvShowDetailService(),
      super(TvShowDetailInitial());

  // ── Internal state ──────────────────────────────────────────────────────────
  final Map<int, TvShow> _similarCache = {};

  // ── Helpers ─────────────────────────────────────────────────────────────────

  List<TvShow> _getSimilarList() => _similarCache.values.toList();

  // ── Public API ───────────────────────────────────────────────────────────────

  Future<void> getTvShowDetail(int id) async {
    emit(TvShowDetailLoading());
    _similarCache.clear();
    try {
      final trailerFuture = tvShowDetailService
          .getTvShowVideoTrailer(id)
          .catchError((_) => null);
      final detailFuture = tvShowDetailService.getTvShowDetail(id);

      final results = await Future.wait<dynamic>([detailFuture, trailerFuture]);
      var tvDetail = results[0] as TvDetail?;
      final videoTrailer = results[1] as String?;

      if (tvDetail == null) {
        emit(TvShowDetailError(message: 'Error'));
        return;
      }

      // Attach trailer key if found
      if (videoTrailer != null) {
        tvDetail = tvDetail.copyWith(keyVideo: videoTrailer);
      }

      List<TvShow>? similar;
      try {
        similar = await tvShowDetailService.getSimilarTvShows(id, 1);
      } catch (_) {
        similar = null;
      }

      if (similar != null) {
        for (var s in similar) {
          _similarCache[s.id] = s;
        }
      }

      emit(
        TvShowDetailLoaded(
          tvDetail: tvDetail,
          similarTvShows: _getSimilarList(),
        ),
      );
    } catch (e) {
      emit(TvShowDetailError(message: 'Error: $e'));
    }
  }
}
