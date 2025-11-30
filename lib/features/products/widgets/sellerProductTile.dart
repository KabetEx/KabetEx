import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/products/data/product.dart';
import 'package:kabetex/providers/theme_provider.dart';

class SellerProductTile extends ConsumerWidget {
  final Product product;
  final void Function(Product) onDelete;
  final void Function(Product) onEdit;

  const SellerProductTile({
    super.key,
    required this.product,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context, ref) {
    final isDark = ref.watch(isDarkModeProvider);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls[0] : '',
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              Container(color: Colors.grey[300], width: 60, height: 60),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[300],
            width: 60,
            height: 60,
            child: const Icon(Icons.error, color: Colors.red),
          ),
        ),
      ),
      title: Text(
        product.title,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 18,
        ),
      ),
      subtitle: Row(
        children: [
          Text(
            product.isActive! ? "Active" : "Inactive",
            style: TextStyle(
              color: product.isActive! ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 8),
          Text('Views: ${product.views}'),
        ],
      ),
      trailing: PopupMenuButton<String>(
        iconColor: isDark ? Colors.white : Colors.black,
        onSelected: (value) {
          if (value == 'edit') {
            onEdit.call(product);
          } else if (value == 'delete') {
            onDelete.call(product);
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'edit', child: Text('Edit')),
          const PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
    );
  }
}
