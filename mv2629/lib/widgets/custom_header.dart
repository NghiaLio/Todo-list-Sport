import 'package:flutter/material.dart';
import 'package:mv2629/constants/theme.dart';
import 'package:mv2629/widgets/button_arrow.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final String leftIconAsset;
  final VoidCallback? onLeftIconTap;
  final String? rightIconAsset;
  final VoidCallback? onRightIconTap;

  const CustomHeader({
    super.key,
    required this.title,
    this.leftIconAsset = 'assets/leftArrow.png',
    this.onLeftIconTap,
    this.rightIconAsset,
    this.onRightIconTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: topPadding),
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: onLeftIconTap ?? () => Navigator.pop(context),
                  child: Container(
                    alignment: Alignment.center,
                    child: ButtonArrow(
                      onPressed: onLeftIconTap ?? () => Navigator.pop(context),
                      iconAsset: leftIconAsset,
                      size: 40,
                    ),
                  ),
                ),
                if (rightIconAsset != null)
                  GestureDetector(
                    onTap: onRightIconTap,
                    child: Container(
                      alignment: Alignment.center,
                      child: ButtonArrow(
                        onPressed: onRightIconTap ?? () {},
                        iconAsset: rightIconAsset!,
                        size: 40,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 40), // Placeholder to keep spacing
              ],
            ),
          ),
          Container(
            height: size.height * 0.1,
            alignment: Alignment.bottomCenter,
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 52.35,
                  color: AppTheme.whiteColor,
                  fontFamily: 'Free-shipping',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

PreferredSizeWidget buildAppBar(BuildContext context, String title) {
  return AppBar(
    backgroundColor: AppTheme.primaryColor,
    leading: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ButtonArrow(onPressed: () => Navigator.pop(context), size: 40),
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
    ),
    bottom: PreferredSize(
      preferredSize: Size.fromHeight(64),
      child: Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 52,
            height: 0.9,
            fontFamily: 'Free-shipping',
            color: AppTheme.whiteColor,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    ),
    centerTitle: true,
  );
}
