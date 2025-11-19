import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/providers/theme_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Scaffold(
      backgroundColor: isDarkMode
          ? Colors.black
          : const Color.fromARGB(255, 237, 228, 225),
      appBar: AppBar(title: const Text('Profile Page')),
      body: const Text('profile  page'),
    );
  }
}
