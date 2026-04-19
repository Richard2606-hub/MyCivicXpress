import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/glass_card.dart';
import '../../core/theme.dart';
import '../../providers/civic_provider.dart';
import '../../models/govtech_models.dart';
import '../profile/profile_view.dart';
import '../profile/digital_id_view.dart';
import '../subsidies/subsidy_hub_view.dart';
import '../complaints/complaint_system_view.dart';
import '../appointments/appointment_hub_view.dart';
import '../ai/civic_ai_chat_view.dart';
import '../renewal/renewal_hub_view.dart';
import '../health/health_dashboard_view.dart';
import '../education/education_hub_view.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(citizenProfileProvider);
    final lang = ref.watch(languageProvider);
    final score = ref.watch(impactScoreProvider);
    final appointment = ref.watch(appointmentProvider);
    final t = AppTranslation.strings[lang]!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.transparent,
            leading: _buildLanguageToggle(ref),
            actions: [
              _buildImpactScoreChip(score),
              const SizedBox(width: 8),
              _buildProfileButton(context),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
              background: Container(
                padding: const EdgeInsets.only(left: 24, bottom: 40),
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t['welcome']!, style: GoogleFonts.outfit(fontSize: 16, color: Colors.white60, letterSpacing: 1)),
                    Text(profile.name, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (appointment != null) ...[
                  _buildAppointmentReminder(context, appointment).animate().fadeIn().slideX(begin: 0.1, end: 0),
                  const SizedBox(height: 24),
                ],
                _buildDigitalIDCard(context, t).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 24),
                _buildSOSButton(context, t).animate().shake(delay: 800.ms),
                const SizedBox(height: 32),
                _buildSectionTitle('Efficiency Tools'),
                const SizedBox(height: 16),
                _buildEfficiencyGrid(context),
                const SizedBox(height: 32),
                _buildSectionTitle(t['quick_actions']!),
                const SizedBox(height: 16),
                _buildQuickActions(context, t),
                const SizedBox(height: 32),
                _buildSectionTitle(t['subsidy']!),
                const SizedBox(height: 16),
                _buildSubsidyPreview(context),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentReminder(BuildContext context, CivicAppointment booking) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppointmentHubView())),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        gradientColors: [const Color(0xFF6366F1).withOpacity(0.3), const Color(0xFF6366F1).withOpacity(0.1)],
        child: Row(
          children: [
            const Icon(LucideIcons.calendarCheck, color: Colors.white, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Upcoming: ${booking.agency}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('${booking.date} at ${booking.time} • TICKET: ${booking.queueNumber}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, color: Colors.white24, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildEfficiencyGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(LucideIcons.bot, 'Ask AI Assistant', const Color(0xFF6366F1), onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CivicAIChatView()));
          }),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(LucideIcons.calendar, 'Unified Booking', const Color(0xFF22D3EE), onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AppointmentHubView()));
          }),
        ),
      ],
    );
  }

  Widget _buildLanguageToggle(WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);
    final langs = ['EN', 'BM', 'CN', 'TN'];
    return Center(
      child: InkWell(
        onTap: () {
          final nextIndex = (langs.indexOf(currentLang) + 1) % langs.length;
          ref.read(languageProvider.notifier).state = langs[nextIndex];
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Text(currentLang, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
    );
  }

  Widget _buildImpactScoreChip(int score) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.amber.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.amber.withOpacity(0.3))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.award, color: Colors.amber, size: 14),
          const SizedBox(width: 4),
          Text('$score pts', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildProfileButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
      child: IconButton(
        icon: const Icon(LucideIcons.user, color: Colors.white, size: 20),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileView())),
      ),
    );
  }

  Widget _buildDigitalIDCard(BuildContext context, Map<String, String> t) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DigitalIDView())),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        gradientColors: [Colors.blue.withOpacity(0.2), Colors.cyan.withOpacity(0.1)],
        child: Row(
          children: [
            const Icon(LucideIcons.qrCode, color: Colors.cyanAccent, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t['digital_id']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const Text('Secure check-in for gov buildings', style: TextStyle(color: Colors.white38, fontSize: 11)),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, color: Colors.white24, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSOSButton(BuildContext context, Map<String, String> t) {
    return GestureDetector(
      onTap: () => _showSOSDialog(context),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFB91C1C)]),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 20, spreadRadius: 2)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.alertOctagon, color: Colors.white),
            const SizedBox(width: 12),
            Text(t['sos']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  void _showSOSDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('EMERGENCY SOS', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: const Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Activating SOS will:', style: TextStyle(color: Colors.white70)),
          SizedBox(height: 12),
          Text('• Call 999 (Simulated)\n• Send your IC & Medical info\n• Broadcast GPS to nearest station', style: TextStyle(color: Colors.white, fontSize: 13)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Colors.white38))),
          ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), child: const Text('CONFIRM SOS')),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, Map<String, String> t) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildActionCard(LucideIcons.fileEdit, t['complaints']!, Colors.orangeAccent, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ComplaintSystemView()))),
        _buildActionCard(LucideIcons.heartPulse, 'Health Hub', AppTheme.secondaryColor, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthDashboardView()))),
        _buildActionCard(LucideIcons.fileText, 'Renewal Hub', AppTheme.primaryColor, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RenewalHubView()))),
        _buildActionCard(LucideIcons.graduationCap, 'Education', Colors.pinkAccent, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EducationHubView()))),
      ],
    );
  }

  Widget _buildActionCard(IconData icon, String title, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle), child: Icon(icon, color: color, size: 28)),
            const SizedBox(height: 16),
            Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildSubsidyPreview(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubsidyHubView())),
      child: GlassCard(
        gradientColors: [Colors.green.withOpacity(0.15), Colors.green.withOpacity(0.05)],
        child: Row(
          children: [
            const Icon(LucideIcons.wallet, color: Colors.greenAccent),
            const SizedBox(width: 16),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('STR Phase 3 Available', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text('RM 600.00 spendable credit', style: TextStyle(color: Colors.white38, fontSize: 11)),
            ])),
            const Icon(LucideIcons.chevronRight, color: Colors.white24, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white));
  }
}
