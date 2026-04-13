import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/tvShowDetail/tvShowDetailState.dart';
import '../../models/tvShow.dart';
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
      // 1. Get Video Trailer first as requested
      final videoTrailer = await tvShowDetailService.getTvShowVideoTrailer(id);

      // 2. Get TV Detail
      var tvDetail = await tvShowDetailService.getTvShowDetail(id);
      if (tvDetail == null) {
        emit(TvShowDetailError(message: 'Error'));
        return;
      }

      // Attach trailer key if found
      if (videoTrailer != null) {
        tvDetail = tvDetail.copyWith(keyVideo: videoTrailer);
      }

      // 3. Get First Page of Similar Shows
      final similar = await tvShowDetailService.getSimilarTvShows(id, 1);
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
