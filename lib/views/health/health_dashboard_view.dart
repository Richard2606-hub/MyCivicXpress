import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/kkm_api_service.dart';
import '../../widgets/health/health_metric_card.dart';

final kkmApiProvider = Provider((ref) => KkmApiService());

class HealthDashboardView extends ConsumerStatefulWidget {
  const HealthDashboardView({super.key});

  @override
  ConsumerState<HealthDashboardView> createState() => _HealthDashboardViewState();
}

class _HealthDashboardViewState extends ConsumerState<HealthDashboardView> {
  Map<String, dynamic>? bloodData;
  Map<String, dynamic>? epiData;
  List<Map<String, String>> facilities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    
    final api = ref.read(kkmApiProvider);
    final fetchedBlood = await api.getLatestBloodDonation();
    final fetchedEpi = await api.getLatestEpidemicData();
    final fetchedFacilities = await api.getNearbyFacilities();

    if (mounted) {
      setState(() {
        bloodData = fetchedBlood;
        epiData = fetchedEpi;
        facilities = fetchedFacilities;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'KKM Health Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        color: const Color(0xFFE91E63),
        backgroundColor: const Color(0xFF1E293B),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Real-Time Metrics', LucideIcons.activity),
              const SizedBox(height: 16),
              
              // Grid for Metrics
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
                children: [
                  HealthMetricCard(
                    title: 'Daily Blood Donations',
                    value: isLoading ? '' : bloodData!['total'].toString(),
                    subtitle: isLoading ? '' : 'As of ${bloodData!['date']}',
                    icon: LucideIcons.droplet,
                    color: Colors.redAccent,
                    isLoading: isLoading,
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
                  
                  HealthMetricCard(
                    title: 'New Epidemic Cases',
                    value: isLoading ? '' : epiData!['cases'].toString(),
                    subtitle: isLoading ? '' : 'As of ${epiData!['date']}',
                    icon: LucideIcons.thermometer,
                    color: Colors.orangeAccent,
                    isLoading: isLoading,
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
                ],
              ),
              
              const SizedBox(height: 40),
              _buildSectionTitle('KKM Directory', LucideIcons.building),
              const SizedBox(height: 16),
              
              // Facilities List
              if (isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Colors.redAccent)))
              else
                ...facilities.asMap().entries.map((entry) {
                  return _buildFacilityCard(entry.value, entry.key);
                }).toList(),
                
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildFacilityCard(Map<String, String> facility, int index) {
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
              color: Colors.blueAccent.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.stethoscope, color: Colors.blueAccent),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  facility['name']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  facility['type']!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(LucideIcons.clock, color: Colors.greenAccent, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      facility['status']!,
                      style: const TextStyle(color: Colors.greenAccent, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.phone, color: Colors.white54),
            onPressed: () {
              // Action to call
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 300 + (index * 100))).slideX(begin: 0.1, end: 0);
  }
}
