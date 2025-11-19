import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kabetex/features/products/data/product.dart';

class SellerProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SellerProductTile({
    super.key,
    required this.product,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        product.isActive! ? "Active" : "Inactive",
        style: TextStyle(color: product.isActive! ? Colors.green : Colors.red),
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') {
            onEdit?.call();
          } else if (value == 'delete') {
            onDelete?.call();
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
