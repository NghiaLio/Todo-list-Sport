// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../models/taskSportCard.dart';

class MediaFilterData {
  final double? minRating;
  final double? maxRating;
  final int? fromYear;
  final int? toYear;
  final SportType? sportType;
  final String? sportKeyword;

  const MediaFilterData({
    this.minRating,
    this.maxRating,
    this.fromYear,
    this.toYear,
    this.sportType,
    this.sportKeyword,
  });

  bool get isEmpty =>
      minRating == null &&
      maxRating == null &&
      fromYear == null &&
      toYear == null &&
      sportType == null &&
      (sportKeyword == null || sportKeyword!.trim().isEmpty);
}

class MediaSearchAndFilterBar extends StatelessWidget {
  const MediaSearchAndFilterBar({
    super.key,
    required this.controller,
    this.onChanged,
    required this.hintText,
    required this.hasActiveFilter,
    required this.onFilterTap,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String hintText;
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
                  hintText: hintText,
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.greyColor,
                  ),
                  prefixIcon: const Icon(Icons.search, color: AppTheme.greyColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
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

class MediaActiveFilterChips extends StatelessWidget {
  const MediaActiveFilterChips({
    super.key,
    required this.filter,
    required this.onClear,
    required this.sportLabel,
  });

  final MediaFilterData filter;
  final VoidCallback onClear;
  final String Function(SportType) sportLabel;

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
      chips.add('🏆 ${sportLabel(filter.sportType!)}');
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
}

class MediaFilterSheet extends StatefulWidget {
  const MediaFilterSheet({
    super.key,
    required this.initialFilter,
    required this.onApply,
    required this.onClear,
    this.keywordHint = 'e.g. marathon, cricket...',
  });

  final MediaFilterData initialFilter;
  final ValueChanged<MediaFilterData> onApply;
  final VoidCallback onClear;
  final String keywordHint;

  @override
  State<MediaFilterSheet> createState() => _MediaFilterSheetState();
}

class _MediaFilterSheetState extends State<MediaFilterSheet> {
  late RangeValues _ratingRange;
  late RangeValues _yearRange;
  SportType? _selectedSport;
  final TextEditingController _keywordCtrl = TextEditingController();

  static const double _minRatingBound = 0;
  static const double _maxRatingBound = 10;
  static const double _minYearBound = 1990;
  static const double _maxYearBound = 2026;

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
    final f = MediaFilterData(
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
              _SectionTitle(
                label: 'Release Year',
                value: '${_yearRange.start.toInt()} – ${_yearRange.end.toInt()}',
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
              const _SectionTitle(label: 'Sport Keyword', value: ''),
              const SizedBox(height: 8),
              TextField(
                controller: _keywordCtrl,
                decoration: InputDecoration(
                  hintText: widget.keywordHint,
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

class MediaGridWidget<T> extends StatelessWidget {
  const MediaGridWidget({
    super.key,
    required this.items,
    required this.showSkeleton,
    this.isLoadingMore = false,
    required this.scrollController,
    required this.itemBuilder,
    required this.skeletonBuilder,
    required this.emptyView,
    required this.gridDelegate,
  });

  final List<T> items;
  final bool showSkeleton;
  final bool isLoadingMore;
  final ScrollController scrollController;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final Widget Function(BuildContext context) skeletonBuilder;
  final Widget emptyView;
  final SliverGridDelegate gridDelegate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverGrid(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (showSkeleton) return skeletonBuilder(context);
              return itemBuilder(context, items[index]);
            }, childCount: showSkeleton ? 9 : items.length),
            gridDelegate: gridDelegate,
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
          if (!showSkeleton && items.isEmpty)
            SliverFillRemaining(hasScrollBody: false, child: emptyView),
        ],
      ),
    );
  }
}

class MediaEmptyView extends StatelessWidget {
  const MediaEmptyView({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: AppTheme.grey300Color),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.greyColor,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
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

class MediaErrorView extends StatelessWidget {
  const MediaErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 64, color: AppTheme.grey400Color),
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
