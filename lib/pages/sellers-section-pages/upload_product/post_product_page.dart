import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kabetex/pages/sellers-section-pages/upload_product/product_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kabetex/services/product_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostProductPage extends StatefulWidget {
  const PostProductPage({super.key});

  @override
  State<PostProductPage> createState() => PostProductPageState();
}

class PostProductPageState extends State<PostProductPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  final productService = ProductService();

  String? _selectedCategory;
  List<XFile> _pickedImages = [];
  bool isUploading = false;

  void _onImagesPicked(List<XFile> images) {
    setState(() {
      _pickedImages = images;
    });
  }

  Future<void> uploadProduct() async {
    //convert XFile images to Uint8list
    List<Uint8List> imagesBytes = [];

    for (var file in _pickedImages) {
      final bytes = await file.readAsBytes();
      imagesBytes.add(bytes);
    }

    if (!_formKey.currentState!.validate() || _pickedImages.isEmpty) {
      // show error
      return;
    }

    setState(() => isUploading = true);

    try {
      // 1. Upload images to Supabase Storage
      final imageUrls = await productService.uploadImages(imagesBytes);

      // 2. Create product in Supabase
      await productService.createProduct(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: _selectedCategory!,
        price: double.parse(_priceController.text.trim()),
        imageUrls: imageUrls,
        sellerId: Supabase.instance.client.auth.currentUser!.id,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product uploaded successfully! 🎉')),
      );

      Navigator.pop(context); // go back after upload
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      setState(() => isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload a product'), centerTitle: true),
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // IMAGE PICKER
                ProductImage(onImagesPicked: _onImagesPicked),
                const SizedBox(height: 16),

                // PRODUCT TITLE
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Product Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Enter product title' : null,
                ),
                const SizedBox(height: 16),

                // CATEGORY DROPDOWN
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Select Category',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Electronics', 'Food', 'Clothes', 'Books']
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val),
                  validator: (val) => val == null ? 'Select a category' : null,
                ),
                const SizedBox(height: 16),

                // DESCRIPTION
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Enter description' : null,
                ),
                const SizedBox(height: 16),

                // PRICE
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Enter price' : null,
                ),
                const SizedBox(height: 24),

                // UPLOAD BUTTON
                ElevatedButton(
                  onPressed: uploadProduct,
                  child: isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Upload Product'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
