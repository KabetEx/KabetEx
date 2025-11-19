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
      //pick images, returns a List<Xfile>
      final pickedFiles = await _picker.pickMultiImage(imageQuality: 80);

      if (pickedFiles.isNotEmpty) {
        setState(() => images = pickedFiles);
        widget.onImagesPicked(
          images.take(3).toList(),
        ); // send to parent max 3 images
      }
    } catch (e) {
      print('Error picking images: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.deepOrange, width: 0.75),
        borderRadius: BorderRadius.circular(8),
      ),
      child: images.isNotEmpty
          ? SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Container(
                      decoration: BoxDecoration(border: Border.all()),
                      child: Image.file(
                        File(images[index].path),
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            )
          : Center(
              child: TextButton.icon(
                onPressed: pickImages,
                icon: const Icon(Icons.upload, color: Colors.black, size: 24),
                label: Text(
                  'Upload upto 3 images',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
    );
  }
}
