import 'package:flutter/material.dart';

class ContactButton extends StatelessWidget {
  const ContactButton({
    super.key,
    required this.isAvailable,
    required this.isContacting,
    required this.contactSeller,
  });

  final bool isAvailable;
  final bool isContacting;
  final VoidCallback contactSeller;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: ElevatedButton(
        onPressed: isAvailable && !isContacting ? contactSeller : null,
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
