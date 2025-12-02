import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/products/providers/product_details_controller.dart';

class ContactButton extends ConsumerWidget {
  const ContactButton({
    super.key,
    required this.isAvailable,
    required this.onpressed,
  });

  final bool isAvailable;
  final VoidCallback onpressed;

  @override
  Widget build(BuildContext context, ref) {
    final isContacting = ref.watch(isContactingProvider);

    return Positioned(
      bottom: 32,
      left: 16,
      right: 16,
      child: ElevatedButton(
        onPressed: isAvailable && !isContacting ? onpressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isAvailable ? Colors.deepOrange : Colors.grey,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: isContacting
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat, color: Colors.white, size: 28),
                  SizedBox(width: 8),
                  Text(
                    'Contact Seller',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
