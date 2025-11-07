import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kabetex/pages/home_page.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

//colorschemes
final kLightColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 255, 145, 0),
);
final kDarkColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 130, 74, 0),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KabetEx',
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
        },
      ),
      themeMode: ThemeMode.system,
      //light mode
      theme: ThemeData().copyWith(
        brightness: Brightness.light,
        colorScheme: kLightColorScheme,
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 245, 236),
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
        scaffoldBackgroundColor: Colors.black,
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
      home: const HomePage(),
    );
  }
}
