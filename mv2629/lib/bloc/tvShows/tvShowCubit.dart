// d:\Lasbom-Dev\Project-dev\mv2629\lib\bloc\tvShows\tvShowCubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/tvShows/tvShowState.dart';
import '../../models/filterTvShow.dart';
import '../../models/tvShow.dart';
import '../../repo/implement/tvShowImp.dart';

class TvShowCubit extends Cubit<TvShowState> {
  final TvShowService tvShowService;

  TvShowCubit({TvShowService? service})
    : tvShowService = service ?? TvShowService(),
      super(TvShowInitial());

  // ── Internal state ──────────────────────────────────────────────────────────
  /// Raw results from API, keyed by id to avoid duplicates.
  final Map<int, TvShow> _cache = {};
  int _page = 1;
  String _keyword = '';
  bool _isLoading = false;
  FilterTvShow _filter = const FilterTvShow();

  // ── Helpers ─────────────────────────────────────────────────────────────────

  /// Apply all local filters on the full cache and return display list.
  List<TvShow> _applyAll() =>
      tvShowService.applyFilter(_cache.values.toList(), _filter);

  TvShowLoaded _buildLoaded({
    bool isLoadingMore = false,
    bool hasReachedMax = false,
  }) => TvShowLoaded(
    tvShows: _applyAll(),
    activeFilter: _filter,
    isLoadingMore: isLoadingMore,
    hasReachedMax: hasReachedMax,
  );

  // ── Public API ───────────────────────────────────────────────────────────────

  /// Called once on screen init.
  Future<void> init() async {
    if (state is TvShowInitial) {
      await _fetchPage(isFirstPage: true);
    }
  }

  /// Infinite-scroll: fetch next page (uses current keyword).
  /// No-op when already loading or has reached the last page.
  Future<void> loadMore() async {
    if (_isLoading) return;
    if (state is TvShowLoaded && (state as TvShowLoaded).hasReachedMax) return;

    await _fetchPage(isFirstPage: false);
  }

  /// Search: resets cache, re-fetches with new keyword.
  /// Filter is preserved across searches.
  Future<void> search(String value) async {
    if (value == _keyword) return;
    _keyword = value;
    _page = 1;
    _cache.clear();
    emit(TvShowLoading());
    await _fetchPage(isFirstPage: true);
  }

  /// Clears search term, reloads discover feed.
  Future<void> clearSearch() async {
    _keyword = '';
    _page = 1;
    _cache.clear();
    emit(TvShowLoading());
    await _fetchPage(isFirstPage: true);
  }

  /// Filter only – never triggers an API call; re-applies on existing cache.
  void updateFilter(FilterTvShow newFilter) {
    if (_filter == newFilter) return;
    _filter = newFilter;
    if (_cache.isEmpty) return;
    emit(_buildLoaded());
  }

  /// Reset all filters and re-display cached data.
  void clearFilter() {
    _filter = const FilterTvShow();
    if (_cache.isEmpty) return;
    emit(_buildLoaded());
  }

  // ── Private ──────────────────────────────────────────────────────────────────

  Future<void> _fetchPage({required bool isFirstPage}) async {
    _isLoading = true;

    // If data already exists, show "loading more" spinner inline.
    if (!isFirstPage && state is TvShowLoaded) {
      emit(_buildLoaded(isLoadingMore: true));
    }

    try {
      final results = _keyword.isEmpty
          ? await tvShowService.discoverTv(_page)
          : await tvShowService.searchTv(_keyword, _page);

      if (results == null) {
        // API error
        if (isFirstPage) {
          emit(TvShowError(message: 'No data found'));
        } else if (state is TvShowLoaded) {
          emit(_buildLoaded(isLoadingMore: false));
        }
        return;
      }

      final bool hasReachedMax = results.isEmpty;

      for (final tv in results) {
        _cache[tv.id] = tv;
      }
      if (!hasReachedMax) _page++;

      emit(_buildLoaded(hasReachedMax: hasReachedMax));
    } catch (e) {
      emit(TvShowError(message: 'System connection error: $e'));
    } finally {
      _isLoading = false;
    }
  }
}
