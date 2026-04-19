import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/renewal_model.dart';
import 'renewal_detail_view.dart';

class RenewalHubView extends StatelessWidget {
  const RenewalHubView({super.key});

  @override
  Widget build(BuildContext context) {
    final renewals = RenewalModel.getMockData();

    return Scaffold(
      backgroundColor: const Color(0xFF0B1120), // Dark theme background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Citizen Renewal Hub',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Manage your essential documents and licenses in one place.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ).animate().fadeIn().slideY(begin: 0.2, end: 0),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  itemCount: renewals.length,
                  itemBuilder: (context, index) {
                    final renewal = renewals[index];
                    return _buildRenewalCard(context, renewal, index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRenewalCard(BuildContext context, RenewalModel renewal, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RenewalDetailView(renewal: renewal),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Hero(
              tag: 'icon_${renewal.id}',
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: renewal.color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(renewal.icon, color: renewal.color, size: 28),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    renewal.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildStatusBadge(renewal.status, renewal.color),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, color: Colors.white38),
          ],
        ),
      ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)).slideX(begin: 0.1, end: 0),
    );
  }

  Widget _buildStatusBadge(String status, Color baseColor) {
    Color badgeColor;
    if (status.contains('Expiring') || status.contains('Action')) {
      badgeColor = Colors.redAccent;
    } else {
      badgeColor = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withOpacity(0.5)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: badgeColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
