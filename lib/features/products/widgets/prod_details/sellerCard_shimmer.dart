import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SellerCardShimmer extends StatelessWidget {
  final bool isDark;

  const SellerCardShimmer({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[600]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[500]!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SizedBox(
        height: 110,
        width: double.infinity,
        child: Card(
          elevation: 0,
          color: isDark ? Colors.grey[900] : Colors.grey[100],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
            child: Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Row(
                children: [
                  // Circle avatar shimmer
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: baseColor,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name & chip shimmer
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Seller + verified chip
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 40,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Seller name shimmer
                        Container(width: 180, height: 16, color: Colors.white),
                        const SizedBox(height: 4),

                        // Whatsapp number shimmer
                        Container(width: 140, height: 18, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
