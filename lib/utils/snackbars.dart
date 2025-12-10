import 'package:flutter/material.dart';

class SuccessSnackBar {
  static void show({
    required BuildContext context,
    required String message,
    required bool isDark,
    void Function()? callback,
    String? label,
    int? duration,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: duration ?? 2),
        backgroundColor: const Color.fromARGB(220, 158, 158, 158),
        elevation: 8,
        behavior: SnackBarBehavior.floating,
        persist: false,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        action: callback != null
            ? SnackBarAction(
                label: label ?? '',
                onPressed: callback,
                backgroundColor: Colors.deepOrange,
                textColor: Colors.white,
              )
            : null,

        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FailureSnackBar {
  static void show({
    required BuildContext context,
    required String message,
    required bool isDark,
    int? duration,
    String? btnLabel,
    void Function()? onPressed,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: duration ?? 1),
        backgroundColor: Colors.red.withAlpha(200),
        elevation: 8,
        behavior: SnackBarBehavior.floating,
        persist: false,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        action: (onPressed != null)
            ? SnackBarAction(
                label: btnLabel!,
                onPressed: onPressed,
                backgroundColor: Colors.black,
                textColor: Colors.white,
              )
            : null,
        content: Row(
          children: [
            const Icon(Icons.error_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
