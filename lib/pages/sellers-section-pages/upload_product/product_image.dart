import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProductImage extends StatefulWidget {
  final void Function(List<XFile>) onImagesPicked;

  const ProductImage({super.key, required this.onImagesPicked});

  @override
  State<ProductImage> createState() => _ProductImageState();
}

class _ProductImageState extends State<ProductImage> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> images = [];

  Future<void> pickImages() async {
    try {
      final pickedFiles = await _picker.pickMultiImage(imageQuality: 80);
      if (pickedFiles.isNotEmpty) {
        setState(() => images = pickedFiles);
        widget.onImagesPicked(images); // send to parent
      }
    } catch (e) {
      print('Error picking images: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(onPressed: pickImages, child: const Text('Pick Images')),
        const SizedBox(height: 10),
        if (images.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Image.file(
                    File(images[index].path),
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
