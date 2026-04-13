import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/movieDetail/movieDetailState.dart';
import '../../models/movie.dart';
import '../../repo/implement/movieDetailImp.dart';
import '../../repo/movieDetailRepo.dart';

class MovieDetailCubit extends Cubit<MovieDetailState> {
  final MovieDetailRepo movieDetailService;

  MovieDetailCubit({MovieDetailRepo? service})
    : movieDetailService = service ?? MovieDetailService(),
      super(MovieDetailInitial());

  // ── Internal state ──────────────────────────────────────────────────────────
  final Map<int, Movie> _similarCache = {};

  // ── Helpers ─────────────────────────────────────────────────────────────────

  List<Movie> _getSimilarList() => _similarCache.values.toList();

  // ── Public API ───────────────────────────────────────────────────────────────

  Future<void> getMovieDetail(int id) async {
    emit(MovieDetailLoading());
    _similarCache.clear();
    try {
      // 1. Get Video Trailer first as requested
      final videoTrailer = await movieDetailService.getMovieVideoTrailer(id);

      // 2. Get TV Detail
      var movieDetail = await movieDetailService.getMovieDetail(id);
      if (movieDetail == null) {
        emit(MovieDetailError(message: 'Error'));
        return;
      }

      // Attach trailer key if found
      if (videoTrailer != null) {
        movieDetail = movieDetail.copyWith(keyVideo: videoTrailer);
      }

      // 3. Get First Page of Similar Shows
      final similar = await movieDetailService.getSimilarMovies(id, 1);
      if (similar != null) {
        for (var s in similar) {
          _similarCache[s.id] = s;
        }
      }

      emit(
        MovieDetailLoaded(
          movieDetail: movieDetail,
          similarMovies: _getSimilarList(),
        ),
      );
    } catch (e) {
      emit(MovieDetailError(message: 'Error: $e'));
    }
  }
}
