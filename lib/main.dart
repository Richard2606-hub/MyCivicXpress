import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme.dart';
import 'views/main_navigation.dart';
import 'views/auth/login_view.dart';
import 'providers/civic_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (Requires flutterfire configure to have been run)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    // We continue so the app still runs in mock mode if Firebase is not yet configured
  }

  runApp(
    const ProviderScope(
      child: MyCivicXpressApp(),
    ),
  );
}

class MyCivicXpressApp extends ConsumerWidget {
  const MyCivicXpressApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'MyCivicXpress',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: isLoggedIn ? const MainNavigation() : const LoginView(),
    );
  }
}
