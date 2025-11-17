import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kabetex/pages/auth/login.dart';
import 'package:kabetex/pages/tabs_screen.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://pxrucvvnywlgpcczrzse.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB4cnVjdnZueXdsZ3BjY3pyenNlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMyMTY0ODksImV4cCI6MjA3ODc5MjQ4OX0.fqMzsjy51ASTnZR1mNBTvxNHUPDDuU5RgeuNFYGt4bs',
  );
  runApp(const ProviderScope(child: MyApp()));
}

//colorschemes
final kLightColorScheme = ColorScheme.fromSeed(seedColor: Colors.deepOrange);
final kDarkColorScheme = ColorScheme.fromSeed(seedColor: Colors.deepOrange);

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
            headlineLarge: GoogleFonts.baloo2(
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
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
            labelLarge: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: kLightColorScheme.onPrimaryContainer,
            ),
            labelMedium: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: kLightColorScheme.onPrimaryContainer,
            ),
            labelSmall: GoogleFonts.lato(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: kLightColorScheme.onPrimaryContainer,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: kLightColorScheme.primary,
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
        home: StreamBuilder(
          stream: Supabase.instance.client.auth.onAuthStateChange,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData) {
              return const LoginPage();
            }
            return const TabsScreen();
          },
        ),
      ),
    );
  }
}
