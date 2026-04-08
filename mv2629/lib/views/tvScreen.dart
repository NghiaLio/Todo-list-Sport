// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mv2629/bloc/tvShows/tvShowCubit.dart';
import 'package:mv2629/bloc/tvShows/tvShowState.dart';
import 'package:mv2629/models/filterTvShow.dart';
import 'package:mv2629/models/taskSportCard.dart';
import 'package:mv2629/models/tvShow.dart';
import 'package:mv2629/constants/theme.dart';
import 'package:mv2629/views/tvShowDetail.dart';
import 'package:mv2629/views/skeleton/image_skeleton.dart';
import 'package:mv2629/views/skeleton/tv_show_card_skeleton.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:mv2629/widgets/custom_header.dart';
import 'package:mv2629/widgets/showSnackBar.dart';
import 'package:mv2629/utils/image_helper.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Screen
// ─────────────────────────────────────────────────────────────────────────────

class Tvscreen extends StatefulWidget {
  const Tvscreen({super.key});

  @override
  State<Tvscreen> createState() => _TvscreenState();
}

class _TvscreenState extends State<Tvscreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    context.read<TvShowCubit>().init();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ── Handlers ─────────────────────────────────────────────────────────────

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (value.trim().isEmpty) {
        context.read<TvShowCubit>().clearSearch();
      } else {
        context.read<TvShowCubit>().search(value.trim());
      }
    });
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) {
      context.read<TvShowCubit>().loadMore();
    }
  }

  void _openFilterSheet(FilterTvShow current) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        initialFilter: current,
        onApply: (newFilter) {
          context.read<TvShowCubit>().updateFilter(newFilter);
        },
        onClear: () {
          context.read<TvShowCubit>().clearFilter();
        },
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.whiteColor,
      appBar: buildAppBar(context, 'TV Shows'),
      body: Column(
        children: [
          // ── Search & Filter bar ──
          BlocBuilder<TvShowCubit, TvShowState>(
            buildWhen: (prev, curr) {
              // Rebuild bar only when filter badge changes
              if (curr is TvShowLoaded && prev is TvShowLoaded) {
                return curr.activeFilter != prev.activeFilter;
              }
              return false;
            },
            builder: (context, state) {
              final activeFilter = state is TvShowLoaded
                  ? state.activeFilter
                  : const FilterTvShow();
              return _SearchAndFilterBar(
                controller: _searchController,
                onChanged: _onSearchChanged,
                hasActiveFilter: !activeFilter.isEmpty,
                onFilterTap: () => _openFilterSheet(activeFilter),
              );
            },
          ),

          // ── Active filter chips ──
          BlocBuilder<TvShowCubit, TvShowState>(
            buildWhen: (prev, curr) =>
                (curr is TvShowLoaded) &&
                (prev is! TvShowLoaded ||
                    (prev).activeFilter != (curr).activeFilter),
            builder: (context, state) {
              if (state is! TvShowLoaded || state.activeFilter.isEmpty) {
                return const SizedBox.shrink();
              }
              return _ActiveFilterChips(
                filter: state.activeFilter,
                onClear: () => context.read<TvShowCubit>().clearFilter(),
              );
            },
          ),

          // ── Grid ──
          Expanded(
            child: BlocConsumer<TvShowCubit, TvShowState>(
              listenWhen: (_, curr) => curr is TvShowError,
              listener: (context, state) {
                if (state is TvShowError) {
                  ShowSnackBar.show(
                    context,
                    message: state.message,
                    type: SnackBarType.error,
                  );
                }
              },
              builder: (context, state) {
                if (state is TvShowLoading || state is TvShowInitial) {
                  return _GridWidget(
                    shows: const [],
                    showSkeleton: true,
                    scrollController: _scrollController,
                  );
                }
                if (state is TvShowLoaded) {
                  return _GridWidget(
                    shows: state.tvShows,
                    showSkeleton: false,
                    isLoadingMore: state.isLoadingMore,
                    scrollController: _scrollController,
                  );
                }
                if (state is TvShowError) {
                  return _ErrorView(
                    message: state.message,
                    onRetry: () => context.read<TvShowCubit>().init(),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GridWidget extends StatelessWidget {
  final List<TvShow> shows;
  final bool showSkeleton;
  final bool isLoadingMore;
  final ScrollController scrollController;

  const _GridWidget({
    required this.shows,
    required this.showSkeleton,
    this.isLoadingMore = false,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverGrid(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (showSkeleton) return const TvShowCardSkeleton();
              return _TvShowCard(show: shows[index]);
            }, childCount: showSkeleton ? 9 : shows.length),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: getValueForScreenType<int>(
                context: context,
                mobile: MediaQuery.of(context).orientation == Orientation.portrait ? 3 : 5,
                tablet: MediaQuery.of(context).orientation == Orientation.portrait ? 4 : 5,
                desktop: 6,
              ),
              childAspectRatio: getValueForScreenType<double>(
                context: context,
                mobile: MediaQuery.of(context).orientation == Orientation.portrait ? 0.55 : 0.65,
                tablet: MediaQuery.of(context).orientation == Orientation.portrait ? 0.60 : 0.7,
                desktop: 0.7,
              ),
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
            ),
          ),
          if (isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          if (!showSkeleton && shows.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyView(),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  TV Show Card
// ─────────────────────────────────────────────────────────────────────────────

class _TvShowCard extends StatelessWidget {
  const _TvShowCard({required this.show});
  final TvShow show;

  @override
  Widget build(BuildContext context) {
    final imageUrl = ImageHelper.getImageUrl(show.posterPath);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TvShowDetail(tvShowId: show.id)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.whiteColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.black10Color,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  color: AppTheme.placeholderDarkColor,
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => const ImageSkeleton(),
                          errorWidget: (_, _, _) =>
                              const Icon(Icons.broken_image),
                        )
                      : const Icon(Icons.tv),
                ),
              ),
              Container(
                color: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 10.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      show.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.whiteColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          show.voteAverage.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.whiteColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.calendar_today_rounded,
                          color: AppTheme.whiteColor,
                          size: 10,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          (show.firstAirDate != null &&
                                  show.firstAirDate!.length >= 4)
                              ? show.firstAirDate!.substring(0, 4)
                              : 'N/A',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.whiteColor,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Search & Filter Bar
// ─────────────────────────────────────────────────────────────────────────────

class _SearchAndFilterBar extends StatelessWidget {
  const _SearchAndFilterBar({
    required this.controller,
    this.onChanged,
    required this.hasActiveFilter,
    required this.onFilterTap,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final bool hasActiveFilter;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.whiteColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.cardBorderColor, width: 1.2),
              ),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: 'Search TV shows...',
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.greyColor,
                  ),
                  prefixIcon: Icon(Icons.search, color: AppTheme.greyColor),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Filter button with badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: hasActiveFilter
                      ? AppTheme.primaryColor
                      : AppTheme.whiteColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.tune_rounded,
                    color: hasActiveFilter
                        ? AppTheme.whiteColor
                        : AppTheme.primaryColor,
                  ),
                  onPressed: onFilterTap,
                ),
              ),
              if (hasActiveFilter)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Active Filter Chips (summary row)
// ─────────────────────────────────────────────────────────────────────────────

class _ActiveFilterChips extends StatelessWidget {
  const _ActiveFilterChips({required this.filter, required this.onClear});
  final FilterTvShow filter;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final chips = <String>[];

    if (filter.minRating != null || filter.maxRating != null) {
      final min = filter.minRating?.toStringAsFixed(1) ?? '0';
      final max = filter.maxRating?.toStringAsFixed(1) ?? '10';
      chips.add('⭐ $min–$max');
    }
    if (filter.fromYear != null || filter.toYear != null) {
      final from = filter.fromYear?.toString() ?? '...';
      final to = filter.toYear?.toString() ?? 'now';
      chips.add('📅 $from–$to');
    }
    if (filter.sportType != null) {
      chips.add('🏆 ${_sportLabel(filter.sportType!)}');
    }
    if (filter.sportKeyword != null && filter.sportKeyword!.trim().isNotEmpty) {
      chips.add('🔑 "${filter.sportKeyword!.trim()}"');
    }

    return Container(
      height: 36,
      margin: const EdgeInsets.only(bottom: 4),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          ...chips.map(
            (label) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    color: AppTheme.whiteColor,
                  ),
                ),
                backgroundColor: AppTheme.primaryColor,
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
          ActionChip(
            label: Text(
              'Clear all',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 11,
                color: Colors.redAccent,
              ),
            ),
            avatar: const Icon(Icons.close, size: 14, color: Colors.redAccent),
            backgroundColor: Colors.red.withOpacity(0.08),
            padding: EdgeInsets.zero,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            onPressed: onClear,
          ),
        ],
      ),
    );
  }

  String _sportLabel(SportType t) {
    switch (t) {
      case SportType.football:
        return 'Football';
      case SportType.basketball:
        return 'Basketball';
      case SportType.volleyball:
        return 'Volleyball';
      case SportType.golf:
        return 'Golf';
      case SportType.rugby:
        return 'Rugby';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Filter Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.initialFilter,
    required this.onApply,
    required this.onClear,
  });

  final FilterTvShow initialFilter;
  final ValueChanged<FilterTvShow> onApply;
  final VoidCallback onClear;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late RangeValues _ratingRange;
  late RangeValues _yearRange;
  SportType? _selectedSport;
  final TextEditingController _keywordCtrl = TextEditingController();

  static const double _minRatingBound = 0;
  static const double _maxRatingBound = 10;
  static const double _minYearBound = 1990;
  static const double _maxYearBound = 2025;

  @override
  void initState() {
    super.initState();
    final f = widget.initialFilter;
    _ratingRange = RangeValues(
      f.minRating ?? _minRatingBound,
      f.maxRating ?? _maxRatingBound,
    );
    _yearRange = RangeValues(
      (f.fromYear ?? _minYearBound.toInt()).toDouble(),
      (f.toYear ?? _maxYearBound.toInt()).toDouble(),
    );
    _selectedSport = f.sportType;
    _keywordCtrl.text = f.sportKeyword ?? '';
  }

  @override
  void dispose() {
    _keywordCtrl.dispose();
    super.dispose();
  }

  bool get _ratingActive =>
      _ratingRange.start > _minRatingBound ||
      _ratingRange.end < _maxRatingBound;
  bool get _yearActive =>
      _yearRange.start > _minYearBound || _yearRange.end < _maxYearBound;

  void _applyFilter() {
    final f = FilterTvShow(
      minRating: _ratingActive ? _ratingRange.start : null,
      maxRating: _ratingActive ? _ratingRange.end : null,
      fromYear: _yearActive ? _yearRange.start.toInt() : null,
      toYear: _yearActive ? _yearRange.end.toInt() : null,
      sportType: _selectedSport,
      sportKeyword: _keywordCtrl.text.trim().isEmpty
          ? null
          : _keywordCtrl.text.trim(),
    );
    widget.onApply(f);
    Navigator.pop(context);
  }

  void _clearAll() {
    widget.onClear();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.whiteColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.grey300Color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Row(
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _clearAll,
                    child: Text(
                      'Clear all',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ],
              ),

              const Divider(),

              // ── Rating ──────────────────────────────────────────────────
              _SectionTitle(
                label: 'Rating',
                value:
                    '${_ratingRange.start.toStringAsFixed(1)} – ${_ratingRange.end.toStringAsFixed(1)}',
              ),
              RangeSlider(
                min: _minRatingBound,
                max: _maxRatingBound,
                divisions: 20,
                activeColor: AppTheme.primaryColor,
                inactiveColor: AppTheme.grey300Color,
                values: _ratingRange,
                labels: RangeLabels(
                  _ratingRange.start.toStringAsFixed(1),
                  _ratingRange.end.toStringAsFixed(1),
                ),
                onChanged: (v) => setState(() => _ratingRange = v),
              ),

              const SizedBox(height: 8),

              // ── Year ─────────────────────────────────────────────────────
              _SectionTitle(
                label: 'Release Year',
                value:
                    '${_yearRange.start.toInt()} – ${_yearRange.end.toInt()}',
              ),
              RangeSlider(
                min: _minYearBound,
                max: _maxYearBound,
                divisions: (_maxYearBound - _minYearBound).toInt(),
                activeColor: AppTheme.primaryColor,
                inactiveColor: AppTheme.grey300Color,
                values: _yearRange,
                labels: RangeLabels(
                  _yearRange.start.toInt().toString(),
                  _yearRange.end.toInt().toString(),
                ),
                onChanged: (v) => setState(() => _yearRange = v),
              ),

              const SizedBox(height: 8),

              // ── Sport Keyword ─────────────────────────────────────────────
              const _SectionTitle(label: 'Sport Keyword', value: ''),
              const SizedBox(height: 8),
              TextField(
                controller: _keywordCtrl,
                decoration: InputDecoration(
                  hintText: 'e.g. marathon, cricket...',
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.greyColor,
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppTheme.greyColor,
                    size: 18,
                  ),
                  filled: true,
                  fillColor: AppTheme.grey100Color,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Sport Type ────────────────────────────────────────────────
              const _SectionTitle(label: 'Sport Type', value: ''),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: SportType.values.map((type) {
                  final selected = _selectedSport == type;
                  return ChoiceChip(
                    label: Text('${_sportEmoji(type)} ${_sportLabel(type)}'),
                    selected: selected,
                    selectedColor: AppTheme.primaryColor,
                    backgroundColor: AppTheme.grey100Color,
                    labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: selected
                          ? AppTheme.whiteColor
                          : AppTheme.grey700Color,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    onSelected: (_) => setState(() {
                      _selectedSport = selected ? null : type;
                    }),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // ── Apply button ──────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _applyFilter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Apply Filters',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _sportLabel(SportType t) {
    switch (t) {
      case SportType.football:
        return 'Football';
      case SportType.basketball:
        return 'Basketball';
      case SportType.volleyball:
        return 'Volleyball';
      case SportType.golf:
        return 'Golf';
      case SportType.rugby:
        return 'Rugby';
    }
  }

  String _sportEmoji(SportType t) {
    switch (t) {
      case SportType.football:
        return '⚽';
      case SportType.basketball:
        return '🏀';
      case SportType.volleyball:
        return '🏐';
      case SportType.golf:
        return '⛳';
      case SportType.rugby:
        return '🏉';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Helper Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (value.isNotEmpty) ...[
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.tv_off_rounded, size: 64, color: AppTheme.grey300Color),
          const SizedBox(height: 12),
          Text(
            'No results found',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.greyColor,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try adjusting your filters or search keyword',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.grey400Color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 64,
            color: AppTheme.grey400Color,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.greyColor,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
