import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'views/main_navigation.dart';
import 'views/auth/login_view.dart';
import 'providers/civic_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: CivicEaseApp(),
    ),
  );
}

class CivicEaseApp extends ConsumerWidget {
  const CivicEaseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'CivicEase AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: isLoggedIn ? const MainNavigation() : const LoginView(),
    );
  }
}
