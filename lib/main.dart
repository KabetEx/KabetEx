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
  seedColor: const Color.fromARGB(255, 255, 145, 0),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KabetEx',
      themeMode: ThemeMode.system,
      //light mode
      theme: ThemeData().copyWith(
        brightness: Brightness.light,
        colorScheme: kLightColorScheme,
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.robotoTextTheme().copyWith(
          titleLarge: GoogleFonts.roboto(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: kLightColorScheme.onPrimaryContainer,
          ),
          titleMedium: GoogleFonts.roboto(
            fontSize: 28,
            color: kLightColorScheme.onPrimaryContainer,
          ),
          titleSmall: GoogleFonts.roboto(
            fontSize: 24,
            color: kLightColorScheme.onPrimaryContainer,
          ),
          labelLarge: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: kLightColorScheme.onPrimaryContainer,
          ),
          labelMedium: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kLightColorScheme.onPrimaryContainer,
          ),
          labelSmall: GoogleFonts.roboto(
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
        textTheme: GoogleFonts.robotoTextTheme().copyWith(
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
