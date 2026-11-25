import 'package:crafty_bay_ecom/core/app_colors.dart';
import 'package:flutter/material.dart';

/// Reusable category tile: rounded icon box with the category name below.
///
/// Used by Home and the Categories page. Receives all data and callbacks
/// via parameters — no provider access or hardcoded text.
class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.name,
    this.iconUrl,
    this.icon,
    this.size = 160,
    this.labelWidth,
    this.onTap,
  }) : assert(iconUrl != null || icon != null);

  /// Tile size for a 4-column layout on the current screen width.
  static double tileSize(BuildContext context) =>
      (MediaQuery.sizeOf(context).width - 100) / 4;

  /// Category icon as a network image or a widget.
  final String? iconUrl;
  final Widget? icon;
  final String name;

  /// Width and height of the icon box. Text is centred under it.
  final double size;
  final double? labelWidth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = size * 0.18;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: size,
              width: size,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(radius),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: size * 0.22,
                vertical: size * 0.19,
              ),
              child:
                  icon ??
                  Image.network(
                    iconUrl!,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => Icon(
                      Icons.image_not_supported_outlined,
                      size: size * 0.34,
                      color: AppColors.logoTeal,
                    ),
                  ),
            ),
            SizedBox(height: size * 0.13),
            SizedBox(
              width: labelWidth ?? size,
              child: Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: size < 68 ? 11 : size * 0.19,
                  fontWeight: FontWeight.w400,
                  color: AppColors.logoTeal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
