import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../widgets/glass_card.dart';
import '../../core/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/civic_provider.dart';
import '../../models/civic_alert.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AlertsView extends ConsumerStatefulWidget {
  const AlertsView({super.key});

  @override
  ConsumerState<AlertsView> createState() => _AlertsViewState();
}

class _AlertsViewState extends ConsumerState<AlertsView> {
  AlertCategory? selectedCategory;

  @override
  Widget build(BuildContext context) {
    final allAlerts = ref.watch(alertsProvider);
    final filteredAlerts = selectedCategory == null 
        ? allAlerts 
        : allAlerts.where((a) => a.category == selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      appBar: AppBar(
        title: const Text(
          'Civic News & Alerts',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: filteredAlerts.length,
              itemBuilder: (context, index) {
                return _buildAlertCard(filteredAlerts[index])
                    .animate()
                    .fadeIn(delay: Duration(milliseconds: 100 * index))
                    .slideY(begin: 0.2, end: 0);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildFilterChip(null, 'All News', LucideIcons.layoutGrid),
          _buildFilterChip(AlertCategory.transport, 'Public Transport', LucideIcons.bus),
          _buildFilterChip(AlertCategory.traffic, 'Traffic', LucideIcons.car),
          _buildFilterChip(AlertCategory.economy, 'Economy', LucideIcons.banknote),
          _buildFilterChip(AlertCategory.weather, 'Weather', LucideIcons.cloudRain),
          _buildFilterChip(AlertCategory.event, 'Events', LucideIcons.flag),
        ],
      ),
    );
  }

  Widget _buildFilterChip(AlertCategory? category, String label, IconData icon) {
    final isSelected = selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = category),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.white70),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(CivicAlert alert) {
    final isUrgent = alert.severity == AlertSeverity.emergency;
    final categoryColor = _getCategoryColor(alert.category);
    final categoryIcon = _getCategoryIcon(alert.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        gradientColors: isUrgent 
            ? [Colors.red.withOpacity(0.15), Colors.transparent] 
            : [categoryColor.withOpacity(0.05), Colors.transparent],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(categoryIcon, size: 14, color: categoryColor),
                    const SizedBox(width: 6),
                    Text(
                      alert.agency,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: categoryColor,
                      ),
                    ),
                  ],
                ),
                Text(
                  _formatTimestamp(alert.timestamp),
                  style: const TextStyle(fontSize: 11, color: Colors.white38),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              alert.title,
              style: const TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              alert.description,
              style: const TextStyle(
                fontSize: 14, 
                color: Colors.white70,
                height: 1.4,
              ),
            ),
            if (alert.isInteractive) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(navigationProvider.notifier).state = 1; // Tab 1 is AI Guide
                    ref.read(guidanceControllerProvider).getGuidance('Give me analysis and advice for this news: ${alert.title}');
                  },
                  icon: const Icon(LucideIcons.sparkles, size: 16),
                  label: const Text('Analyze with AI Assistant'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: categoryColor.withOpacity(0.2),
                    foregroundColor: categoryColor,
                    elevation: 0,
                    side: BorderSide(color: categoryColor.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(AlertCategory category) {
    switch (category) {
      case AlertCategory.transport: return Colors.blueAccent;
      case AlertCategory.economy: return Colors.greenAccent;
      case AlertCategory.traffic: return Colors.orangeAccent;
      case AlertCategory.weather: return Colors.cyanAccent;
      case AlertCategory.event: return Colors.purpleAccent;
      case AlertCategory.safety: return Colors.redAccent;
    }
  }

  IconData _getCategoryIcon(AlertCategory category) {
    switch (category) {
      case AlertCategory.transport: return LucideIcons.bus;
      case AlertCategory.economy: return LucideIcons.banknote;
      case AlertCategory.traffic: return LucideIcons.car;
      case AlertCategory.weather: return LucideIcons.cloudRain;
      case AlertCategory.event: return LucideIcons.flag;
      case AlertCategory.safety: return LucideIcons.shieldAlert;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('dd MMM').format(timestamp);
    }
  }
}
