import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dashboard/dashboard_view.dart';
import 'service_navigation/ai_assistant_view.dart';
import 'emergency/alerts_view.dart';
import 'history/history_view.dart';
import 'transit/transit_dashboard_view.dart';
import 'weather/weather_map_view.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/civic_provider.dart';
import '../widgets/fancy_background.dart';

class MainNavigation extends ConsumerWidget {
  const MainNavigation({super.key});

  final List<Widget> _pages = const [
    DashboardView(),
    AIAssistantView(),
    TransitDashboardView(),
    WeatherMapView(),
    AlertsView(),
    CivicHistoryView(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationProvider);

    return FancyBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: IndexedStack(
          index: selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.8),
            border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
          ),
          child: BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: (index) => ref.read(navigationProvider.notifier).state = index,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: const Color(0xFF6366F1),
            unselectedItemColor: Colors.white38,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(LucideIcons.layoutDashboard, size: 20),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(LucideIcons.bot, size: 20),
                label: 'AI Guide',
              ),
              BottomNavigationBarItem(
                icon: Icon(LucideIcons.bus, size: 20),
                label: 'Transit',
              ),
              BottomNavigationBarItem(
                icon: Icon(LucideIcons.cloudSun, size: 20),
                label: 'Weather',
              ),
              BottomNavigationBarItem(
                icon: Icon(LucideIcons.bellRing, size: 20),
                label: 'Alerts',
              ),
              BottomNavigationBarItem(
                icon: Icon(LucideIcons.history, size: 20),
                label: 'History',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
