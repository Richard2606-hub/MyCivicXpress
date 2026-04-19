import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/civic_provider.dart';

class SchoolSuggesterView extends ConsumerWidget {
  const SchoolSuggesterView({super.key});

  // Generates mock schools based on the user's location string
  List<Map<String, String>> _getMockSchools(String location) {
    // Clean up location or default to Kuala Lumpur
    final loc = location.trim().isEmpty ? 'Kuala Lumpur' : location.trim();
    
    return [
      {'name': 'SK $loc Utama', 'type': 'Primary (SK)', 'distance': '1.2 km'},
      {'name': 'SJK(C) Chung Hwa $loc', 'type': 'Primary (SJKC)', 'distance': '2.5 km'},
      {'name': 'SMK $loc', 'type': 'Secondary (SMK)', 'distance': '1.8 km'},
      {'name': 'SMK Agama $loc', 'type': 'Secondary (Islamic)', 'distance': '3.4 km'},
      {'name': 'Sekolah Antarabangsa $loc', 'type': 'International', 'distance': '5.0 km'},
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(citizenProfileProvider);
    final location = profile.location;
    final hasLocation = location.trim().isNotEmpty;
    final schools = _getMockSchools(location);

    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Nearby Schools', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.mapPin, color: Color(0xFF6366F1)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hasLocation ? 'Showing schools near $location' : 'Location not set',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ).animate().fadeIn().slideX(),
            
            const SizedBox(height: 8),
            
            Text(
              hasLocation 
                  ? 'Based on your personal profile settings.' 
                  : 'Please update your Personal Details on the Dashboard to see nearby schools.',
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
            ).animate().fadeIn(delay: 200.ms),
            
            const SizedBox(height: 32),
            
            if (!hasLocation)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.mapPinOff, color: Colors.white.withOpacity(0.2), size: 64),
                      const SizedBox(height: 16),
                      const Text('No Location Set', style: TextStyle(color: Colors.white, fontSize: 20)),
                    ],
                  ).animate().fadeIn(delay: 400.ms),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: schools.length,
                  itemBuilder: (context, index) {
                    final school = schools[index];
                    return _buildSchoolCard(school, index);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchoolCard(Map<String, String> school, int index) {
    final isPrimary = school['type']!.contains('Primary');
    final color = isPrimary ? Colors.tealAccent : Colors.amberAccent;
    final icon = isPrimary ? LucideIcons.backpack : LucideIcons.bookOpen;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  school['name']!,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  school['type']!,
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(LucideIcons.navigation, color: Color(0xFF6366F1), size: 16),
              const SizedBox(height: 4),
              Text(
                school['distance']!,
                style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 200 + (index * 100))).slideY(begin: 0.1, end: 0);
  }
}
