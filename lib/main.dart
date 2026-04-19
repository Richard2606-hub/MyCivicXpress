import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'views/dashboard/dashboard_view.dart';
import 'views/auth/login_view.dart';
import 'providers/civic_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (Requires flutterfire configure to have been run)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Firebase initialization failed: $e');
    // We continue so the app still runs in mock mode if Firebase is not yet configured
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'CivicEase AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.outfitTextTheme(),
      ),
      home: isLoggedIn ? const DashboardView() : const LoginView(),
    );
  }
}
