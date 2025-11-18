import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/models/product.dart';
import 'package:kabetex/pages/auth/sign_up.dart';
import 'package:kabetex/pages/sellers-section-pages/upload_product/product_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kabetex/providers/categories/categories_provider.dart';
import 'package:kabetex/providers/categories/selected_category.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:kabetex/services/product_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostProductPage extends ConsumerStatefulWidget {
  const PostProductPage({super.key});

  @override
  ConsumerState<PostProductPage> createState() => PostProductPageState();
}

class PostProductPageState extends ConsumerState<PostProductPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  final productService = ProductService();
  final user = Supabase.instance.client.auth.currentUser;

  String _selectedCategory = 'all';
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

      final profile = await Supabase.instance.client
          .from('profiles')
          .select('phone_number')
          .eq('id', user!.id)
          .single();

      final sellerNumber = profile['phoneNumber'];
      // 2. Create product in Supabase
      await productService.createProduct(
        Product(
          title: _titleController.text,
          category: _selectedCategory,
          description: _descController.text,
          price: double.tryParse(_priceController.text)!,
          imageUrls: imageUrls,
          sellerId: user!.id,
          sellerNumber: profile['phone_number'],
        ),
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
    final allCategories = ref.watch(allCategoriesProvider);
    final isDark = ref.watch(isDarkModeProvider);

    if (user == null) {
      return Scaffold(
        backgroundColor: isDark
            ? Colors.black
            : const Color.fromARGB(255, 237, 228, 225),
        appBar: AppBar(
          title: const Text('Upload a product'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('You have to create \n an account to post'),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SignupPage()),
                  );
                },
                child: const Text('Create an account'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Upload a product'), centerTitle: true),
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
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
                    hintText: 'Product Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Enter product title' : null,
                ),
                const SizedBox(height: 16),

                // CATEGORY DROPDOWN
                Stack(
                  children: [
                    SizedBox(
                      height: 64,
                      child: DropdownButtonFormField<Map<String, dynamic>>(
                        initialValue: allCategories[0], //defaults to 'all'
                        decoration: const InputDecoration(
                          hintText: 'Select Category',
                          border: OutlineInputBorder(),
                        ),
                        items: allCategories
                            .map(
                              (cat) => DropdownMenuItem<Map<String, dynamic>>(
                                value: cat,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors
                                        .deepOrange, // background for individual item
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    textAlign: TextAlign.center,
                                    cat['name'],
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedCategory = val!['name']),
                        validator: (val) =>
                            val == null ? _selectedCategory : null,
                      ),
                    ), // sizedBox
                    const Positioned(
                      right: 4,
                      bottom: 4,
                      top: 0,
                      child: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.deepOrangeAccent,
                        size: 54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // DESCRIPTION
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    hintText: 'Description',
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
                  decoration: InputDecoration(
                    hintText: 'Price',
                    border: const OutlineInputBorder(),
                    prefixText: 'KSH ',
                    prefixStyle: Theme.of(context).textTheme.labelSmall!,
                  ),
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall!.copyWith(fontWeight: FontWeight.bold),
                  keyboardType: TextInputType.number,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Enter price' : null,
                ),
                const SizedBox(height: 24),

                // UPLOAD BUTTON
                GestureDetector(
                  onTap: uploadProduct,
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.deepOrange,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 5,
                          color: Colors.grey[700]!,
                          offset: const Offset(1, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: isUploading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'upload',
                              style: Theme.of(context).textTheme.bodyLarge!
                                  .copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
