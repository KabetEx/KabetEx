import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/products/data/product.dart';
import 'package:kabetex/features/products/providers/prod_details_provider.dart';

class ReportProduct extends ConsumerWidget {
  const ReportProduct({super.key, required this.isDark, required this.product});

  final bool isDark;
  final Product product;

  @override
  Widget build(BuildContext context, ref) {
    final controller = ref.watch(
      productDetailsControllerProvider(product).notifier,
    );

    return PopupMenuButton<String>(
      color: Colors.white,
      icon: Icon(Icons.more_vert, color: isDark ? Colors.white : Colors.black),
      onSelected: (value) {
        if (value == 'report') {
          controller.showReportDialog(context, product);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'report',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.flag_outlined, size: 20, color: Colors.black),
              const SizedBox(width: 8),
              Text(
                'Report product',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge!.copyWith(color: Colors.black),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
