import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mv2629/bloc/movieDetail/movieDetailCubit.dart';
import 'package:mv2629/bloc/movieDetail/movieDetailState.dart';
import 'package:mv2629/constants/theme.dart';
import 'package:mv2629/views/skeleton/tv_show_detail_skeleton.dart';
import 'package:mv2629/widgets/media_detail_widgets.dart';

class MovieScreenDetail extends StatelessWidget {
  const MovieScreenDetail({super.key, required this.movieId});

  final int movieId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MovieDetailCubit()..getMovieDetail(movieId),
      child: _MovieScreenDetailView(movieId: movieId),
    );
  }
}

class _MovieScreenDetailView extends StatefulWidget {
  const _MovieScreenDetailView({required this.movieId});

  final int movieId;

  @override
  State<_MovieScreenDetailView> createState() => __MovieScreenDetailViewState();
}

class __MovieScreenDetailViewState extends State<_MovieScreenDetailView> {
  final ScrollController _similarScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _similarScrollController.addListener(_onSimilarScroll);
  }

  @override
  void dispose() {
    _similarScrollController.dispose();
    super.dispose();
  }

  void _onSimilarScroll() {
    if (_similarScrollController.position.pixels >=
        _similarScrollController.position.maxScrollExtent - 200) {
      context.read<MovieDetailCubit>().loadMoreSimilar(widget.movieId);
    }
  }

  void _onRetry() {
    context.read<MovieDetailCubit>().getMovieDetail(widget.movieId);
  }

  void _onPlayTrailer() {
    
  }

  void _onTapSimilarMovie(int id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MovieScreenDetail(movieId: id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.whiteColor,
      body: SafeArea(
        child: BlocBuilder<MovieDetailCubit, MovieDetailState>(
          buildWhen: (previous, current) {
            if (previous.runtimeType != current.runtimeType) return true;
            if (previous is MovieDetailLoaded && current is MovieDetailLoaded) {
              return previous.movieDetail != current.movieDetail;
            }
            return true;
          },
          builder: (context, state) {
            if (state is MovieDetailLoading || state is MovieDetailInitial) {
              return const TvShowDetailSkeleton();
            }

            if (state is MovieDetailError) {
              return _buildErrorState(context, state.message);
            }

            if (state is MovieDetailLoaded) {
              return BlocBuilder<MovieDetailCubit, MovieDetailState>(
                buildWhen: (previous, current) =>
                    current is MovieDetailLoaded &&
                    (previous is! MovieDetailLoaded ||
                        previous.similarMovies != current.similarMovies ||
                        previous.isLoadingMore != current.isLoadingMore),
                builder: (context, innerState) {
                  final loaded = innerState as MovieDetailLoaded;
                  final detail = loaded.movieDetail;

                  return MediaDetailContent(
                    model: MediaDetailViewModel(
                      name: detail.name,
                      dateText: detail.getFirstAirDate(),
                      overview: detail.overview,
                      posterPath: detail.posterPath,
                      keyVideo: detail.keyVideo,
                      episodeRuntime: detail.getEpisodeRuntime(),
                      totalRuntime: detail.getTotalRuntime(),
                      totalEpisodes: detail.durationFallback,
                      originalLanguage: detail.originalLanguage,
                      genres: detail.getGenres(),
                    ),
                    similarItems: loaded.similarMovies
                        .map((e) => MediaPosterItem(id: e.id, posterPath: e.posterPath))
                        .toList(),
                    isLoadingMore: loaded.isLoadingMore,
                    similarScrollController: _similarScrollController,
                    onBack: () => Navigator.of(context).pop(),
                    onPlayTrailer: _onPlayTrailer,
                    onTapSimilar: _onTapSimilarMovie,
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Error: $message'),
          ElevatedButton(onPressed: _onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
