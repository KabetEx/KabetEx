import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/products/data/product.dart';
import 'package:kabetex/features/products/data/product_services.dart';
import 'package:kabetex/providers/categories/categories_provider.dart';
import 'package:kabetex/providers/seller_products/my_products.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProductPage extends ConsumerStatefulWidget {
  const EditProductPage({super.key, required this.product});
  final Product product;

  @override
  ConsumerState<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends ConsumerState<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late final _titleController = TextEditingController(
    text: widget.product.title,
  );
  late final TextEditingController _descController = TextEditingController(
    text: widget.product.description,
  );
  late final TextEditingController _priceController = TextEditingController(
    text: widget.product.price.toString(),
  );
  late String _selectedCategory = widget.product.category;

  bool isUpdating = false;

  final productService = ProductService();
  final user = Supabase.instance.client.auth.currentUser;

  void updateProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      setState(() {
        isUpdating = true;
      });

      await productService.updateProduct(
        widget.product.id!,
        _titleController.text,
        _descController.text,
        _priceController.text,
        _selectedCategory,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Update succesfull ')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update : $e')));
    } finally {
      setState(() {
        isUpdating = false;
        ref.refresh(myProductsProvider);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allCategories = ref.watch(allCategoriesProvider);
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Update Product'),
        backgroundColor: isDark ? Colors.black : Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // PRODUCT TITLE
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'New Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Enter updated title' : null,
                ),
                const SizedBox(height: 16),

                // CATEGORY DROPDOWN
                // CATEGORY DROPDOWN - Updated with your design + icon
                Stack(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: InputDecoration(
                        hintText: 'Select Category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      items: allCategories.map((cat) {
                        return DropdownMenuItem<String>(
                          value: cat['name'],
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.deepOrange,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              cat['name'],
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge!
                                  .copyWith(fontSize: 14, color: Colors.white),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setState(() => _selectedCategory = val!),
                      validator: (val) =>
                          val == null ? 'Please select a category' : null,
                    ),
                    // Your arrow icon positioned correctly
                    const Positioned(
                      right: 12,
                      top: 0,
                      bottom: 0,
                      child: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.deepOrangeAccent,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // DESCRIPTION
                TextFormField(
                  controller: _descController,
                  decoration: InputDecoration(
                    hintText: 'Description',
                    hintStyle: Theme.of(context).textTheme.labelSmall!,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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
                    hintStyle: Theme.of(context).textTheme.labelSmall!.copyWith(
                      fontSize: 8,
                      color: Colors.grey,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    prefixText: 'KSH ',
                    prefixStyle: Theme.of(context).textTheme.labelSmall!,
                  ),
                  //user input text style
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall!.copyWith(fontWeight: FontWeight.bold),
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Enter updated price';
                    }
                    if (double.tryParse(val) == null) {
                      return 'Enter valid price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // UPLOAD BUTTON
                GestureDetector(
                  onTap: updateProduct,
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
                      child: isUpdating
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Update',
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
