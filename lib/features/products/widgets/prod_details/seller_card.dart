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
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: sellerAsync.when(
        loading: () => SellerCardShimmer(isDark: isDark),
        error: (e, st) => Text('Error: $e'),
        data: (profile) {
          if (profile == null) return const Text('Seller not found');

          final isVerified = profile['isVerified'] ?? false;
          final sellerName = profile['full_name'] ?? 'Guest';
          final sellerNumber = profile['phone_number'] ?? '-';

          return SizedBox(
            height: 110,
            child: Card(
              elevation: 0,
              color: isDark ? Colors.grey[900] : Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 12,
                ),
                child: Row(
                  children: [
                    const CircleAvatar(radius: 20, child: Icon(Icons.person)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Seller',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Chip(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                side: const BorderSide(
                                  color: Colors.transparent,
                                ),
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isVerified
                                          ? Icons.verified
                                          : Icons.verified_user_outlined,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isVerified ? 'Verified' : 'Unverified',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: isVerified
                                    ? Colors.green
                                    : Colors.grey[600],
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Name: $sellerName',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            'Whatsapp number: $sellerNumber',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
