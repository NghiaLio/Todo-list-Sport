import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/movieDetail/movieDetailState.dart';
import '../../models/movie.dart';
import '../../models/movieDetailModel.dart';
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
      final trailerFuture = movieDetailService
          .getMovieVideoTrailer(id)
          .catchError((_) => null);
      final detailFuture = movieDetailService.getMovieDetail(id);

      final results = await Future.wait<dynamic>([detailFuture, trailerFuture]);
      var movieDetail = results[0] as MovieDetail?;
      final videoTrailer = results[1] as String?;

      if (movieDetail == null) {
        emit(MovieDetailError(message: 'Error'));
        return;
      }

      // Attach trailer key if found
      if (videoTrailer != null) {
        movieDetail = movieDetail.copyWith(keyVideo: videoTrailer);
      }

      List<Movie>? similar;
      try {
        similar = await movieDetailService.getSimilarMovies(id, 1);
      } catch (_) {
        similar = null;
      }

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
