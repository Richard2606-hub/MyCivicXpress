import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/civic_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/fancy_background.dart';
import '../../models/govtech_models.dart';

class SubsidyHubView extends ConsumerWidget {
  const SubsidyHubView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subsidies = ref.watch(subsidyProvider);
    
    return FancyBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Welfare & Subsidies'),
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildWalletSummary(subsidies).animate().fadeIn().slideY(begin: 0.1, end: 0),
            const SizedBox(height: 32),
            const Text(
              'Available Programs',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...subsidies.map((s) => _buildSubsidyCard(s)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletSummary(List<GovtSubsidy> subsidies) {
    final total = subsidies.where((s) => s.isEligible).fold(0.0, (sum, s) => sum + s.amount);
    
    return GlassCard(
      gradientColors: [
        const Color(0xFF10B981).withOpacity(0.2),
        const Color(0xFF059669).withOpacity(0.05),
      ],
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Spendable Balance', style: TextStyle(color: Colors.white70)),
              Icon(LucideIcons.wallet, color: Colors.greenAccent, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'RM ${total.toStringAsFixed(2)}',
            style: GoogleFonts.outfit(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.qrCode, size: 18),
                  label: const Text('Pay with Subsidy'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white10,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubsidyCard(GovtSubsidy subsidy) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    subsidy.name,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: subsidy.isEligible ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    subsidy.isEligible ? 'ELIGIBLE' : 'NOT ELIGIBLE',
                    style: TextStyle(
                      color: subsidy.isEligible ? Colors.greenAccent : Colors.redAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(subsidy.description, style: const TextStyle(color: Colors.white60, fontSize: 13)),
            const Divider(height: 32, color: Colors.white10),
            const Text('Recent History', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...subsidy.history.map((h) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(LucideIcons.history, size: 12, color: Colors.white24),
                  const SizedBox(width: 8),
                  Text(h, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            )),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.05, end: 0);
  }
}
