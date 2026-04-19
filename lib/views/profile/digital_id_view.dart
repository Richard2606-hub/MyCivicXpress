import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../providers/civic_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/fancy_background.dart';

class DigitalIDView extends ConsumerWidget {
  const DigitalIDView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(citizenProfileProvider);
    
    return FancyBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('MyDigital ID'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              _buildDigitalCard(profile).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
              const SizedBox(height: 48),
              const Text(
                'SCAN FOR VERIFICATION',
                style: TextStyle(color: Colors.white38, letterSpacing: 2, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: QrImageView(
                  data: 'Verified_Citizen_${profile.icNumber}',
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ).animate().fadeIn(delay: 400.ms).rotate(begin: 0.1, end: 0),
              const SizedBox(height: 16),
              const Text(
                'Rotating secure key: 15s remaining',
                style: TextStyle(color: Colors.white30, fontSize: 12),
              ),
              const SizedBox(height: 64),
              _buildSecurityInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDigitalCard(profile) {
    return GlassCard(
      padding: EdgeInsets.zero,
      gradientColors: [
        const Color(0xFF6366F1).withOpacity(0.2),
        const Color(0xFF22D3EE).withOpacity(0.1),
      ],
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'KERAJAAN MALAYSIA',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const Icon(LucideIcons.shieldCheck, color: Colors.blueAccent, size: 20),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(LucideIcons.user, color: Colors.white30, size: 40),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        profile.icNumber,
                        style: const TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 1),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.location.toUpperCase(),
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'STATUS: VERIFIED',
                          style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.lock, size: 14, color: Colors.white38),
            SizedBox(width: 8),
            Text(
              'End-to-End Encrypted Identity',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Approved by JPN & National Cyber Security Agency',
          style: TextStyle(color: Colors.white.withOpacity(0.1), fontSize: 10),
        ),
      ],
    );
  }
}
