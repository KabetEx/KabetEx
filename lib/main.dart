import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kabetex/features/auth/presentation/login.dart';
import 'package:kabetex/features/home/presentations/tabs_screen.dart';
import 'package:kabetex/features/cart/data/product_hive.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //----------supabase----------//
  await Supabase.initialize(
    url: 'https://pxrucvvnywlgpcczrzse.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB4cnVjdnZueXdsZ3BjY3pyenNlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMyMTY0ODksImV4cCI6MjA3ODc5MjQ4OX0.fqMzsjy51ASTnZR1mNBTvxNHUPDDuU5RgeuNFYGt4bs',
  );

  //----------------hive------------//
  await Hive.initFlutter();
  Hive.registerAdapter(ProductHiveAdapter());
  // settings box for storing small app prefs like theme
  await Hive.openBox('settings');
  final settingsBox = Hive.box('settings');

  // read saved theme (default false => light)
  final savedIsDark =
      settingsBox.get('isDarkMode', defaultValue: false) as bool;

  await Hive.openBox<ProductHive>('cartBox');

  // create a ProviderContainer seeded with the saved theme
  final container = ProviderContainer(
    overrides: [isDarkModeProvider.overrideWith((ref) => savedIsDark)],
  );

  // run the app with that container
  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

//colorschemes
final kLightColorScheme = ColorScheme.fromSeed(
  seedColor: Colors.deepOrange,
  brightness: Brightness.light,
);
final kDarkColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 91, 31, 12),
  brightness: Brightness.dark,
);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return MaterialApp(
      title: 'KabetEx',
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

      //light mode
      theme: ThemeData().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 222, 216, 216),
        canvasColor: const Color.fromARGB(255, 237, 228, 225),
        brightness: Brightness.light,
        colorScheme: kLightColorScheme,
        appBarTheme: const AppBarThemeData().copyWith(
          backgroundColor: const Color.fromARGB(255, 222, 216, 216),
          centerTitle: true,
          titleTextStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Colors.deepOrange,
            fontWeight: FontWeight.bold,
            fontSize: 32,
            fontFamily: 'Poppins',
          ),
          iconTheme: IconThemeData(
            color: isDarkMode
                ? const Color.fromARGB(255, 237, 228, 225)
                : Colors.black,
          ),
        ),
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          headlineLarge: GoogleFonts.baloo2(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          titleLarge: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          titleMedium: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Colors.black,
          ),
          titleSmall: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.black,
          ),
          labelLarge: GoogleFonts.lato(fontSize: 16, color: Colors.black),
          labelMedium: GoogleFonts.lato(fontSize: 14, color: Colors.black),
          labelSmall: GoogleFonts.lato(fontSize: 12, color: Colors.black),
          bodyLarge: GoogleFonts.lato(fontSize: 14, color: Colors.black),
          bodyMedium: GoogleFonts.lato(fontSize: 14, color: Colors.black),
          bodySmall: GoogleFonts.lato(fontSize: 14, color: Colors.black),
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
        scaffoldBackgroundColor: Colors.black,
        canvasColor: Colors.black,
        appBarTheme: AppBarThemeData(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          centerTitle: true,
          titleTextStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Colors.deepOrange,
            fontWeight: FontWeight.bold,
            fontSize: 32,
            fontFamily: 'Poppins',
          ),
            color: isDarkMode
                ? const Color.fromARGB(255, 237, 228, 225)
                : Colors.black,
          ),
        ),
        brightness: Brightness.dark,
        colorScheme: kDarkColorScheme,
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          titleLarge: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titleMedium: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titleSmall: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          labelLarge: GoogleFonts.lato(fontSize: 16, color: Colors.white),
          labelMedium: GoogleFonts.lato(fontSize: 14, color: Colors.white),
          labelSmall: GoogleFonts.lato(fontSize: 12, color: Colors.white),
          bodyLarge: GoogleFonts.lato(fontSize: 14, color: Colors.white),
          bodyMedium: GoogleFonts.lato(fontSize: 14, color: Colors.white),
          bodySmall: GoogleFonts.lato(fontSize: 14, color: Colors.white),
        ),
      ),
      home: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          final user = Supabase.instance.client.auth.currentUser;
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (user == null) {
            return const LoginPage();
          }
          return const TabsScreen();
        },
      ),
    );
  }
}
