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
  int _page = 1;
  bool _isLoading = false;
  final Map<int, TvShow> _similarCache = {};

  // ── Helpers ─────────────────────────────────────────────────────────────────

  List<TvShow> _getSimilarList() => _similarCache.values.toList();

  // ── Public API ───────────────────────────────────────────────────────────────

  Future<void> getTvShowDetail(int id) async {
    emit(TvShowDetailLoading());
    _page = 1;
    _similarCache.clear();
    _isLoading = true;
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
      final similar = await tvShowDetailService.getSimilarTvShows(id, _page);
      if (similar != null) {
        for (var s in similar) {
          _similarCache[s.id] = s;
        }
        if (similar.isNotEmpty) _page++;
      }

      emit(
        TvShowDetailLoaded(
          tvDetail: tvDetail,
          similarTvShows: _getSimilarList(),
          hasReachedMax: similar?.isEmpty ?? true,
        ),
      );
    } catch (e) {
      emit(TvShowDetailError(message: 'Error: $e'));
    } finally {
      _isLoading = false;
    }
  }

  Future<void> loadMoreSimilar(int id) async {
    if (_isLoading) return;
    final currentState = state;
    if (currentState is! TvShowDetailLoaded || currentState.hasReachedMax) {
      return;
    }

    _isLoading = true;
    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final similar = await tvShowDetailService.getSimilarTvShows(id, _page);
      if (similar == null) {
        emit(currentState.copyWith(isLoadingMore: false));
        return;
      }

      for (var s in similar) {
        _similarCache[s.id] = s;
      }

      final bool hasReachedMax = similar.isEmpty;
      if (!hasReachedMax) _page++;

      emit(
        currentState.copyWith(
          similarTvShows: _getSimilarList(),
          isLoadingMore: false,
          hasReachedMax: hasReachedMax,
        ),
      );
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    } finally {
      _isLoading = false;
    }
  }
}
