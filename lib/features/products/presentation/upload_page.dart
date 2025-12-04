import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/core/snackbars.dart';
import 'package:kabetex/features/products/data/product.dart';
import 'package:kabetex/features/auth/presentation/sign_up.dart';
import 'package:kabetex/features/products/providers/user_provider.dart';
import 'package:kabetex/features/products/widgets/prod_details/product_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kabetex/providers/categories/categories_provider.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:kabetex/features/products/data/product_services.dart';
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
  final TextEditingController _quantityController = TextEditingController();
  String _selectedCategory = 'electronics';

  final productService = ProductService();
  final user = Supabase.instance.client.auth.currentUser;

  List<XFile> _pickedImages = [];
  bool isUploading = false;

  void _onImagesPicked(List<XFile> images) {
    setState(() {
      _pickedImages = images;
    });
  }

  Future<void> uploadProduct() async {
    final isDark = ref.watch(isDarkModeProvider);
    //convert XFile images to Uint8list
    List<Uint8List> imagesBytes = [];

    if (!_formKey.currentState!.validate()) {
      // show error
      return;
    }
    if (_pickedImages.isEmpty) {
      FailureSnackBar.show(
        context: context,
        message: 'No images selected',
        isDark: isDark,
      );
      return;
    }

    for (var file in _pickedImages) {
      final bytes = await file.readAsBytes();
      imagesBytes.add(bytes);
    }

    setState(() => isUploading = true);

    try {
      // 1. Upload images to Supabase Storage
      final imageUrls = await productService.uploadImages(imagesBytes);

      final seller = await productService.getSellerprofile(user!.id);
      final sellerNumber = seller!['phone_number'] as String;

      // 2. Create Product object in Supabase
      await productService.createProduct(
        Product(
          title: _titleController.text,
          category: _selectedCategory,
          description: _descController.text,
          quantity: int.tryParse(_quantityController.text)!,
          price: double.tryParse(_priceController.text)!,
          imageUrls: imageUrls,
          sellerId: user!.id,
          sellerNumber: sellerNumber,
        ),
      );

      ref.refresh(myProductsProvider); //refresh my products

      SuccessSnackBar.show(
        context: context,
        isDark: isDark,
        message: 'Product uploaded successfully! 🎉',
      );

      Navigator.pop(context); // go back after upload
    } catch (e) {
      FailureSnackBar.show(
        context: context,
        message: 'Upload failed: $e',
        isDark: isDark,
      );
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
          title: Text(
            'Upload',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'You need to have \n an account to post',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SignupPage()),
                  );
                },
                child: Text(
                  'Create an account',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Upload', style: Theme.of(context).textTheme.titleLarge),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Form(
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
                  ProdTitle(titleController: _titleController, isDark: isDark),
                  const SizedBox(height: 16),

                  // CATEGORY & quantity DROPDOWN
                  CategoryRow(
                    allCategories: allCategories,
                    quantityController: _quantityController,
                    onSelectedCat: (value) {
                      setState(() {
                        _selectedCategory = value!['name'];
                      });
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(height: 22),

                  // DESCRIPTION
                  DescriptionField(
                    isDark: isDark,
                    descController: _descController,
                  ),
                  const SizedBox(height: 16),

                  // PRICE
                  PriceField(isDark: isDark, priceController: _priceController),
                  const SizedBox(height: 24),

                  // UPLOAD BUTTON
                  UploadBtn(
                    isUploading: isUploading,
                    uploadProduct: uploadProduct,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProdTitle extends StatelessWidget {
  const ProdTitle({
    super.key,
    required this.titleController,
    required this.isDark,
  });

  final TextEditingController titleController;
  final bool isDark;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: titleController,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            width: 0.5,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.deepOrange),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        label: const Text('Title'),
        labelStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 16,
        ),
      ),
      style: Theme.of(context).textTheme.labelSmall!.copyWith(
        color: isDark ? Colors.grey[200] : Colors.grey[900],
        fontSize: 18,
        height: 1.5,
        fontFamily: 'inter',
      ),
      validator: (val) =>
          val == null || val.isEmpty ? 'Enter product title' : null,
    );
  }
}

class CategoryRow extends StatefulWidget {
  const CategoryRow({
    super.key,
    required this.allCategories,
    required this.quantityController,
    required this.onSelectedCat,
    required this.isDark,
  });

  final List<Map<String, dynamic>> allCategories;
  final TextEditingController quantityController;
  final ValueChanged<Map<String, dynamic>?>? onSelectedCat;
  final bool isDark;

  @override
  State<CategoryRow> createState() => _CategoryRowState();
}

class _CategoryRowState extends State<CategoryRow> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: DropdownButtonFormField<Map<String, dynamic>>(
            initialValue: widget.allCategories[0], //defaults to 'all'
            isExpanded: true,
            decoration: InputDecoration(
              hintText: 'Select Category',
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: widget.isDark ? Colors.white : Colors.black,
                  width: 0.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.deepOrange),
              ),

              suffixIcon: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.arrow_drop_down_circle_outlined),
              ),
            ),

            items: widget.allCategories
                .map(
                  (cat) => DropdownMenuItem<Map<String, dynamic>>(
                    value: cat,

                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            Colors.deepOrange, // background for individual item
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        textAlign: TextAlign.center,
                        cat['name'],
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: widget.onSelectedCat,
            validator: (val) {
              if (val == null) return "Select a category";
              return null;
            },
          ),
        ),

        const SizedBox(width: 12),

        //quantity
        Flexible(
          child: TextFormField(
            autocorrect: false,
            keyboardType: TextInputType.number,
            autofocus: false,
            controller: widget.quantityController,
            decoration: InputDecoration(
              label: const Text('Quantity'),
              labelStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: widget.isDark ? Colors.white : Colors.black,
                fontSize: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  width: 0.5,
                  color: widget.isDark ? Colors.white : Colors.black,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.deepOrange),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),

            validator: (value) {
              final quantity = int.tryParse(widget.quantityController.text);
              if (value == null || value.isEmpty) {
                return 'Invalid quantity';
              } else if (quantity == null) {
                FailureSnackBar.show(
                  context: context,
                  message: 'Enter a valid quantity',
                  isDark: widget.isDark,
                );
                return 'Invalid quantity';
              }

              return null;
            },
          ),
        ),
      ],
    );
  }
}

class DescriptionField extends StatelessWidget {
  const DescriptionField({
    super.key,
    required this.isDark,
    required this.descController,
  });

  final bool isDark;
  final TextEditingController descController;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: descController,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        label: const Text('Description'),
        labelStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 16,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            width: 0.5,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.deepOrange),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
      maxLines: 3,
      //user input text style
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
        color: isDark ? Colors.white : Colors.black,
        fontSize: 18,
        height: 1.5,
        fontFamily: 'Open Sans',
      ),
      validator: (val) =>
          val == null || val.isEmpty ? 'Enter description' : null,
    );
  }
}

class PriceField extends StatelessWidget {
  const PriceField({
    super.key,
    required this.isDark,
    required this.priceController,
  });

  final bool isDark;
  final TextEditingController priceController;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: priceController,
      decoration: InputDecoration(
        label: const Text('Price'),
        labelStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 16,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            width: 0.5,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.deepOrange),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        prefixText: 'KSH ',
        prefixStyle: Theme.of(context).textTheme.labelSmall!.copyWith(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 18,
        ),
      ),
      //user input text style
      style: Theme.of(context).textTheme.labelSmall!.copyWith(
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.grey[900],
        fontSize: 18,
        height: 1.5,
        fontFamily: 'inter',
      ),
      keyboardType: TextInputType.number,
      validator: (val) => val == null || val.isEmpty ? 'Enter price' : null,
    );
  }
}

class UploadBtn extends StatelessWidget {
  const UploadBtn({
    super.key,
    required this.isUploading,
    required this.uploadProduct,
  });

  final bool isUploading;
  final void Function() uploadProduct;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUploading ? null : uploadProduct,
      child: Container(
        height: 58,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.deepOrange,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: isUploading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : Text(
                  'Upload',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
