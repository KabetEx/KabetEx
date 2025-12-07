import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PostWidgetShimmer extends StatelessWidget {
  const PostWidgetShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Shimmer.fromColors(
        baseColor: isDark ? Colors.grey[900]! : Colors.grey[400]!,
        highlightColor: isDark ? Colors.grey[800]! : Colors.grey[500]!,
        direction: ShimmerDirection.rtl,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar placeholder
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Colors.grey[800]! : Colors.grey[800]!,
              ),
            ),

            const SizedBox(width: 12),

            // Right content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Username + timestamp
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 16,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: isDark ? Colors.grey[800]! : Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 40,
                        height: 14,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: isDark ? Colors.grey[800]! : Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Post content placeholder
                  Container(
                    width: double.infinity,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: isDark ? Colors.grey[800]! : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Action buttons row
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? Colors.grey[800]! : Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),

                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? Colors.grey[800]! : Colors.white,
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
    );
  }
}
