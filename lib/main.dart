import 'package:aplicacionlensys/auth/loader.dart';
import 'package:aplicacionlensys/auth/login.dart';
import 'package:aplicacionlensys/auth/recovery.dart';
import 'package:aplicacionlensys/auth/register.dart';
import 'package:aplicacionlensys/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'custom/configurations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: Configurations.mSupabaseUrl,
    anonKey: Configurations.mSupabaseKey,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Lensys Evaluación',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
           textTheme: GoogleFonts.robotoTextTheme(),
      ),
      routes: {
        '/loaderScreen': (_) => const LoaderScreen(),
        '/login': (_) => const Login(),
        '/register': (_) => const RegisterScreen(),
        '/recovery': (_) => const Recovery(),
        '/home': (_) => const HomeScreen(),
      },
      home: const LoaderScreen(),
    );
  }
}
