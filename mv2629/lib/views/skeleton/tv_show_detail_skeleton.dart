import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:mv2629/constants/theme.dart';
import 'package:shimmer/shimmer.dart';

class TvShowDetailSkeleton extends StatelessWidget {
  const TvShowDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Shimmer.fromColors(
        baseColor: AppTheme.grey300Color,
        highlightColor: AppTheme.grey100Color,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: getValueForScreenType<double>(
                  context: context,
                  mobile:
                      MediaQuery.of(context).orientation == Orientation.portrait
                      ? MediaQuery.of(context).size.width * 0.65
                      : MediaQuery.of(context).size.width * 0.45,
                  tablet:
                      MediaQuery.of(context).orientation == Orientation.portrait
                      ? MediaQuery.of(context).size.width * 0.55
                      : MediaQuery.of(context).size.width * 0.45,
                  desktop: MediaQuery.of(context).size.width * 0.35,
                ),
                height: getValueForScreenType<double>(
                  context: context,
                  mobile:
                      MediaQuery.of(context).orientation == Orientation.portrait
                      ? MediaQuery.of(context).size.height * 0.4
                      : MediaQuery.of(context).size.height * 0.5,
                  tablet:
                      MediaQuery.of(context).orientation == Orientation.portrait
                      ? MediaQuery.of(context).size.height * 0.35
                      : MediaQuery.of(context).size.height * 0.5,
                  desktop: MediaQuery.of(context).size.height * 0.6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.whiteColor,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.52,
                height: 28,
                decoration: BoxDecoration(
                  color: AppTheme.whiteColor,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.38,
                height: 22,
                decoration: BoxDecoration(
                  color: AppTheme.whiteColor,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: Container(
                width: getValueForScreenType<double>(
                  context: context,
                  mobile:
                      MediaQuery.of(context).orientation == Orientation.portrait
                      ? MediaQuery.of(context).size.width * 0.65
                      : MediaQuery.of(context).size.width * 0.45,
                  tablet:
                      MediaQuery.of(context).orientation == Orientation.portrait
                      ? MediaQuery.of(context).size.width * 0.55
                      : MediaQuery.of(context).size.width * 0.45,
                  desktop: MediaQuery.of(context).size.width * 0.35,
                ),
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.whiteColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const _TitleBlockWidget(),
            const SizedBox(height: 8),
            ...List.generate(5, (_) => const _InfoRowBlockWidget()),
            const SizedBox(height: 12),
            const _TitleBlockWidget(),
            const SizedBox(height: 16),
            SizedBox(
              height: getValueForScreenType<double>(
                context: context,
                mobile:
                    MediaQuery.of(context).orientation == Orientation.portrait
                    ? MediaQuery.of(context).size.height * 0.25
                    : MediaQuery.of(context).size.height * 0.35,
                tablet:
                    MediaQuery.of(context).orientation == Orientation.portrait
                    ? MediaQuery.of(context).size.height * 0.2
                    : MediaQuery.of(context).size.height * 0.35,
                desktop: MediaQuery.of(context).size.height * 0.45,
              ),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, _) => Container(
                  width: getValueForScreenType<double>(
                    context: context,
                    mobile:
                        MediaQuery.of(context).orientation ==
                            Orientation.portrait
                        ? MediaQuery.of(context).size.width * 0.33
                        : MediaQuery.of(context).size.width * 0.2,
                    tablet:
                        MediaQuery.of(context).orientation ==
                            Orientation.portrait
                        ? MediaQuery.of(context).size.width * 0.25
                        : MediaQuery.of(context).size.width * 0.2,
                    desktop: MediaQuery.of(context).size.width * 0.15,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.whiteColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemCount: 4,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _TitleBlockWidget extends StatelessWidget {
  const _TitleBlockWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.34,
      height: 20,
      decoration: BoxDecoration(
        color: AppTheme.whiteColor,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class _InfoRowBlockWidget extends StatelessWidget {
  const _InfoRowBlockWidget();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 110,
            height: 10,
            decoration: BoxDecoration(
              color: AppTheme.whiteColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 14,
            decoration: BoxDecoration(
              color: AppTheme.whiteColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: AppTheme.whiteColor, thickness: 1),
        ],
      ),
    );
  }
}
