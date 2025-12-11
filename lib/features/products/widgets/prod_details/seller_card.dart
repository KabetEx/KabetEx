import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/products/providers/seller_provider.dart';
import 'package:kabetex/features/products/widgets/prod_details/sellerCard_shimmer.dart';

class SellerCard extends ConsumerWidget {
  const SellerCard({super.key, required this.sellerId, required this.isDark});

  final String sellerId;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sellerAsync = ref.watch(sellerProfileProvider(sellerId));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: sellerAsync.when(
        loading: () => SellerCardShimmer(isDark: isDark),
        error: (e, st) => Text('Error: $e'),
        data: (profile) {
          final isVerified = profile?.isVerified ?? false;
          final sellerName = profile?.name ?? 'Guest';
          final sellerNumber = profile?.pNumber ?? '-';

          return Card(
            margin: const EdgeInsets.all(4),
            color: isDark ? Colors.grey[900] : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: CachedNetworkImageProvider(
                      profile?.avatarUrl ?? '',
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Text section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Seller',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white : Colors.grey[900],
                                fontWeight: FontWeight.w200,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: isVerified
                                    ? Colors.green.withAlpha(100)
                                    : Colors.grey.withAlpha(100),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isVerified
                                        ? Icons.verified_rounded
                                        : Icons.shield_outlined,
                                    size: 14,
                                    color: isVerified
                                        ? Colors.greenAccent[700]
                                        : Colors.grey[300],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isVerified ? 'Verified' : 'Unverified',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: isVerified
                                          ? Colors.greenAccent[700]
                                          : Colors.grey[300],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Text(
                          sellerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.grey[900],
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          'WhatsApp: $sellerNumber',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
