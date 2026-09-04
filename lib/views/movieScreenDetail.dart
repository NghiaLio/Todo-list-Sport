import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/movieDetail/movieDetailCubit.dart';
import '../bloc/movieDetail/movieDetailState.dart';
import '../constants/app_config.dart';
import '../constants/theme.dart';
import '../views/skeleton/tv_show_detail_skeleton.dart';
import '../widgets/media_detail_widgets.dart';

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
  void dispose() {
    _similarScrollController.dispose();
    super.dispose();
  }

  void _onRetry() {
    context.read<MovieDetailCubit>().getMovieDetail(widget.movieId);
  }

  void _onPlayTrailer(String key) async {
    final youtubeUrl = AppConfig.baseUrlYoutube;
    final url = Uri.parse('$youtubeUrl$key');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch trailer')),
        );
      }
    }
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
                        previous.similarMovies != current.similarMovies),
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
                      isMovie: true,
                    ),
                    similarItems: loaded.similarMovies
                        .map(
                          (e) => MediaPosterItem(
                            id: e.id,
                            posterPath: e.posterPath,
                          ),
                        )
                        .toList(),
                    similarScrollController: _similarScrollController,
                    onBack: () => Navigator.of(context).pop(),
                    onPlayTrailer: () => _onPlayTrailer(detail.keyVideo ?? ''),
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
