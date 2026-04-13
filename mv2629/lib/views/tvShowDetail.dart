import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../bloc/tvShowDetail/tvShowDetailCubit.dart';
import '../bloc/tvShowDetail/tvShowDetailState.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/theme.dart';
import '../views/skeleton/tv_show_detail_skeleton.dart';
import '../widgets/media_detail_widgets.dart';

class TvShowDetail extends StatelessWidget {
  const TvShowDetail({super.key, required this.tvShowId});

  final int tvShowId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TvShowDetailCubit()..getTvShowDetail(tvShowId),
      child: _TvShowDetailView(tvShowId: tvShowId),
    );
  }
}

class _TvShowDetailView extends StatefulWidget {
  const _TvShowDetailView({required this.tvShowId});

  final int tvShowId;

  @override
  State<_TvShowDetailView> createState() => __TvShowDetailViewState();
}

class __TvShowDetailViewState extends State<_TvShowDetailView> {
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
      context.read<TvShowDetailCubit>().loadMoreSimilar(widget.tvShowId);
    }
  }

  void _onRetry() {
    context.read<TvShowDetailCubit>().getTvShowDetail(widget.tvShowId);
  }

  Future<void> _onPlayTrailer(String key) async {
    final youtubeUrl = dotenv.env['BASE_URL_YOUTUBE'] ?? 'https://www.youtube.com/watch?v=';
    final url = Uri.parse('$youtubeUrl$key');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch trailer')),
        );
      }
    }
  }

  void _onTapSimilarShow(int showId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TvShowDetail(tvShowId: showId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.whiteColor,
      body: SafeArea(
        child: BlocBuilder<TvShowDetailCubit, TvShowDetailState>(
          buildWhen: (previous, current) {
            if (previous.runtimeType != current.runtimeType) return true;
            if (previous is TvShowDetailLoaded && current is TvShowDetailLoaded) {
              return previous.tvDetail != current.tvDetail;
            }
            return true;
          },
          builder: (context, state) {
            if (state is TvShowDetailLoading || state is TvShowDetailInitial) {
              return const TvShowDetailSkeleton();
            }

            if (state is TvShowDetailError) {
              return _buildErrorState(context, state.message);
            }

            if (state is TvShowDetailLoaded) {
              return BlocBuilder<TvShowDetailCubit, TvShowDetailState>(
                buildWhen: (previous, current) =>
                    current is TvShowDetailLoaded &&
                    (previous is! TvShowDetailLoaded ||
                        previous.similarTvShows != current.similarTvShows ||
                        previous.isLoadingMore != current.isLoadingMore),
                builder: (context, innerState) {
                  final loaded = innerState as TvShowDetailLoaded;
                  final tv = loaded.tvDetail;

                  return MediaDetailContent(
                    model: MediaDetailViewModel(
                      name: tv.name,
                      dateText: tv.getFirstAirDate(),
                      overview: tv.overview,
                      posterPath: tv.posterPath,
                      keyVideo: tv.keyVideo,
                      episodeRuntime: tv.getEpisodeRuntime(),
                      totalRuntime: tv.getTotalRuntime(),
                      totalEpisodes: tv.numberOfEpisodes,
                      originalLanguage: tv.originalLanguage,
                      genres: tv.getGenres(),
                    ),
                    similarItems: loaded.similarTvShows
                        .map((e) => MediaPosterItem(id: e.id, posterPath: e.posterPath))
                        .toList(),
                    isLoadingMore: loaded.isLoadingMore,
                    similarScrollController: _similarScrollController,
                    onBack: () => Navigator.of(context).pop(),
                    onPlayTrailer: () {
                      if (tv.keyVideo != null) {
                        _onPlayTrailer(tv.keyVideo!);
                      }
                    },
                    onTapSimilar: _onTapSimilarShow,
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
