import 'package:flutter/material.dart';
import 'package:mv2629/constants/theme.dart';
import 'package:shimmer/shimmer.dart';

class ImageSkeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const ImageSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.grey300Color,
      highlightColor: AppTheme.grey100Color,
      child: Container(
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.whiteColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
