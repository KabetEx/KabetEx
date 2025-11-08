import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/pages/tabs_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kabetex/providers/theme_provider.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

//colorschemes
final kLightColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 255, 145, 0),
);
final kDarkColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 130, 74, 0),
);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final isLightMode = ref.watch(isDarkModeProvider);

    return AnimatedTheme(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      data: isLightMode
          ? ThemeData(brightness: Brightness.light)
          : ThemeData(brightness: Brightness.dark),
      child: MaterialApp(
        title: 'KabetEx',
        debugShowCheckedModeBanner: false,
        themeMode: isLightMode ? ThemeMode.light : ThemeMode.dark,

        //light mode
        theme: ThemeData().copyWith(
          brightness: Brightness.light,
          colorScheme: kLightColorScheme,
          textTheme: GoogleFonts.poppinsTextTheme().copyWith(
            titleLarge: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: kLightColorScheme.onPrimaryContainer,
            ),
            titleMedium: GoogleFonts.poppins(
              fontSize: 28,
              color: kLightColorScheme.onPrimaryContainer,
            ),
            titleSmall: GoogleFonts.poppins(
              fontSize: 24,
              color: kLightColorScheme.onPrimaryContainer,
            ),
            labelLarge: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kLightColorScheme.onPrimaryContainer,
            ),
            labelMedium: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kLightColorScheme.onPrimaryContainer,
            ),
            labelSmall: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: kLightColorScheme.onPrimaryContainer,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: kLightColorScheme.onPrimaryContainer,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        //darktheme
        darkTheme: ThemeData.dark().copyWith(
          brightness: Brightness.dark,
          colorScheme: kDarkColorScheme,
          textTheme: GoogleFonts.poppinsTextTheme().copyWith(
            titleLarge: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: kLightColorScheme.primary,
            ),
            titleMedium: GoogleFonts.poppins(
              fontSize: 28,
              color: kLightColorScheme.onPrimaryContainer,
            ),
            titleSmall: GoogleFonts.poppins(
              fontSize: 24,
              color: kLightColorScheme.onPrimaryContainer,
            ),
            labelLarge: GoogleFonts.poppins(
              fontSize: 20,
              color: kLightColorScheme.onPrimaryContainer,
            ),
            labelMedium: GoogleFonts.poppins(
              fontSize: 18,
              color: kLightColorScheme.onPrimaryContainer,
            ),
            labelSmall: GoogleFonts.poppins(
              fontSize: 16,
              color: kLightColorScheme.onPrimaryContainer,
            ),
          ),
        ),
        home: const TabsScreen(),
      ),
    );
  }
}
