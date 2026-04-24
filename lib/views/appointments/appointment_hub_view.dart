import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../providers/civic_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/fancy_background.dart';

class AppointmentHubView extends ConsumerStatefulWidget {
  const AppointmentHubView({super.key});

  @override
  ConsumerState<AppointmentHubView> createState() => _AppointmentHubViewState();
}

class _AppointmentHubViewState extends ConsumerState<AppointmentHubView> {
  String _selectedAgency = 'JPN (MyKad)';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTime = '10:00 AM';
  bool _isBooking = false;

  final List<String> _agencies = ['JPN (MyKad)', 'Immigration (Passport)', 'JPJ (License)', 'LHDN (Tax)', 'Klinik Kesihatan'];
  final List<String> _times = ['9:00 AM', '10:00 AM', '11:00 AM', '2:00 PM', '3:00 PM', '4:00 PM'];

  Future<void> _bookAppointment() async {
    setState(() => _isBooking = true);
    await Future.delayed(const Duration(seconds: 1));
    
    final appointment = CivicAppointment(
      agency: _selectedAgency,
      date: DateFormat('MMM dd, yyyy').format(_selectedDate),
      time: _selectedTime,
      queueNumber: 'A-${100 + (DateTime.now().millisecondsSinceEpoch % 900)}',
      estWaitTime: 15,
    );

    ref.read(appointmentProvider.notifier).setAppointment(appointment);
    
    if (mounted) {
      setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentBooking = ref.watch(appointmentProvider);

    return FancyBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Appointment Hub'),
          backgroundColor: Colors.transparent,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (currentBooking != null) ...[
                _buildSectionTitle('Your Active Ticket'),
                const SizedBox(height: 16),
                _buildQueueTicket(currentBooking).animate().fadeIn().scale(),
                const SizedBox(height: 40),
                const Divider(color: Colors.white10),
                const SizedBox(height: 24),
              ],
              _buildSectionTitle('Book New Appointment'),
              const SizedBox(height: 8),
              const Text('Unified cross-agency booking system', style: TextStyle(color: Colors.white38, fontSize: 13)),
              const SizedBox(height: 32),
              _buildAgencySelector(),
              const SizedBox(height: 24),
              _buildDateTimeSelector(),
              const SizedBox(height: 40),
              _buildBookingButton(),
              const SizedBox(height: 48),
              _buildEfficiencyStats(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQueueTicket(CivicAppointment booking) {
    return GlassCard(
      gradientColors: [
        const Color(0xFF6366F1).withValues(alpha: 0.25),
        const Color(0xFF22D3EE).withValues(alpha: 0.1),
      ],
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.agency, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18), overflow: TextOverflow.ellipsis),
                    Text('${booking.date} • ${booking.time}', style: const TextStyle(color: Colors.white60, fontSize: 12), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(LucideIcons.qrCode, color: Colors.white, size: 40),
            ],
          ),
          const Divider(height: 32, color: Colors.white24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTicketInfo('QUEUE NO.', booking.queueNumber),
              _buildTicketInfo('EST. WAIT', '${booking.estWaitTime} MIN'),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.clock, color: Colors.greenAccent, size: 14),
                SizedBox(width: 8),
                Text('TIME SAVED: 45 MINS', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketInfo(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _buildAgencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Agency', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedAgency,
              isExpanded: true,
              dropdownColor: const Color(0xFF0F172A),
              style: const TextStyle(color: Colors.white),
              items: _agencies.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
              onChanged: (val) => setState(() => _selectedAgency = val!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSelector() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Booking Date', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: Color(0xFF6366F1),
                            onPrimary: Colors.white,
                            surface: Color(0xFF1E293B),
                            onSurface: Colors.white,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null && picked != _selectedDate) {
                    setState(() => _selectedDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.calendar, color: Colors.white54, size: 18),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('MMM dd, yyyy').format(_selectedDate),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Time Slot', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedTime,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF0F172A),
                    style: const TextStyle(color: Colors.white),
                    items: _times.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) => setState(() => _selectedTime = val!),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookingButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isBooking ? null : _bookAppointment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isBooking
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Confirm Booking', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEfficiencyStats() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Icon(LucideIcons.barChart3, color: Colors.amberAccent, size: 32),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SYSTEM EFFICIENCY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Unified digital booking reduces national queue wait times by 65%.', style: TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold));
  }
}
