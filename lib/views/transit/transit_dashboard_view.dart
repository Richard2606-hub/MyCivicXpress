import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/transit_api_service.dart';
import '../../models/transit_model.dart';
import '../../widgets/transit/station_card.dart';
import '../../providers/civic_provider.dart';

// Provider for the API service
final transitApiProvider = Provider((ref) => TransitApiService());

class TransitDashboardView extends ConsumerStatefulWidget {
  const TransitDashboardView({super.key});

  @override
  ConsumerState<TransitDashboardView> createState() => _TransitDashboardViewState();
}

class _TransitDashboardViewState extends ConsumerState<TransitDashboardView> {
  List<TransitLine> lines = [];
  List<TransitStation> currentStations = [];
  List<TransitStation> nearbyStations = [];
  List<StationArrival> arrivals = [];
  
  String selectedLineId = 'all';
  String? selectedStationId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final api = ref.read(transitApiProvider);
    final profile = ref.read(citizenProfileProvider);
    
    final fetchedLines = await api.getLines();
    final fetchedNearby = await api.getNearbyStations(profile.location);
    final fetchedStations = await api.getStationsByLine(selectedLineId);

    if (mounted) {
      setState(() {
        lines = fetchedLines;
        nearbyStations = fetchedNearby;
        currentStations = fetchedStations;
        if (fetchedNearby.isNotEmpty && selectedStationId == null) {
          selectedStationId = fetchedNearby.first.id;
        } else if (fetchedStations.isNotEmpty && selectedStationId == null) {
          selectedStationId = fetchedStations.first.id;
        }
      });
      _fetchArrivals();
    }
  }

  Future<void> _fetchArrivals() async {
    if (selectedStationId == null) return;
    
    setState(() => isLoading = true);
    final api = ref.read(transitApiProvider);
    final fetchedArrivals = await api.getArrivals(selectedStationId!);

    if (mounted) {
      setState(() {
        arrivals = fetchedArrivals;
        isLoading = false;
      });
    }
  }

  Future<void> _changeLine(String lineId) async {
    setState(() {
      selectedLineId = lineId;
      isLoading = true;
    });
    
    final api = ref.read(transitApiProvider);
    final fetchedStations = await api.getStationsByLine(lineId);
    
    if (mounted) {
      setState(() {
        currentStations = fetchedStations;
        if (fetchedStations.isNotEmpty) {
          selectedStationId = fetchedStations.first.id;
        }
      });
      _fetchArrivals();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(citizenProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _initializeData,
          color: const Color(0xFF6366F1),
          backgroundColor: const Color(0xFF1E293B),
          child: CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      _buildLineSelector(),
                      const SizedBox(height: 24),
                      _buildStationSelector(),
                      const SizedBox(height: 32),
                      _buildSectionTitle('Nearby in ${profile.location}', LucideIcons.mapPin),
                      const SizedBox(height: 16),
                      _buildNearbyStationsSection(),
                      const SizedBox(height: 32),
                      _buildSectionTitle('Live Arrivals', LucideIcons.radio),
                      const SizedBox(height: 16),
                      _buildArrivalsList(),
                      const SizedBox(height: 100), // Bottom padding for FAB
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFF6366F1),
        icon: const Icon(LucideIcons.map, color: Colors.white),
        label: const Text('View Network Map', style: TextStyle(color: Colors.white)),
      ).animate().scale(delay: 500.ms, duration: 300.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      expandedHeight: 80,
      floating: true,
      centerTitle: false,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.train, color: Color(0xFF6366F1), size: 24),
          ),
          const SizedBox(width: 12),
          const Text(
            'Transit Hub',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineSelector() {
    return SizedBox(
      height: 45,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildLineChip('all', 'All Lines', Colors.grey),
          ...lines.map((line) => _buildLineChip(line.id, line.name, line.color)),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildLineChip(String id, String name, Color color) {
    final isSelected = selectedLineId == id;
    return GestureDetector(
      onTap: () => _changeLine(id),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Center(
          child: Text(
            name,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStationSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedStationId,
          isExpanded: true,
          dropdownColor: const Color(0xFF1E293B),
          icon: const Icon(LucideIcons.chevronDown, color: Colors.white54),
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          hint: const Text('Select Station', style: TextStyle(color: Colors.white54)),
          items: currentStations.map((station) {
            return DropdownMenuItem(
              value: station.id,
              child: Text(station.name),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                selectedStationId = newValue;
              });
              _fetchArrivals();
            }
          },
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6366F1), size: 18),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildNearbyStationsSection() {
    if (nearbyStations.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: nearbyStations.length,
        itemBuilder: (context, index) {
          final station = nearbyStations[index];
          final isSelected = selectedStationId == station.id;
          
          return GestureDetector(
            onTap: () {
              setState(() => selectedStationId = station.id);
              _fetchArrivals();
            },
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 16, bottom: 4),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6366F1).withOpacity(0.2) : const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? const Color(0xFF6366F1) : Colors.white.withOpacity(0.05),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    station.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${station.lineIds.length} Lines Available',
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)).slideX(begin: 0.2, end: 0);
        },
      ),
    );
  }

  Widget _buildArrivalsList() {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(color: Color(0xFF6366F1)),
        ),
      );
    }

    if (arrivals.isEmpty) {
      return Center(
        child: Column(
          children: [
            const Icon(LucideIcons.clock, color: Colors.white10, size: 64),
            const SizedBox(height: 16),
            Text(
              'No upcoming arrivals found',
              style: TextStyle(color: Colors.white.withOpacity(0.4)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: arrivals.map((arrival) {
        // Find the line for this arrival (simplified mock logic)
        final lineId = selectedLineId == 'all' ? 'mrt_kg' : selectedLineId;
        final line = lines.firstWhere((l) => l.id == lineId, orElse: () => lines.first);
        
        return ArrivalCard(arrival: arrival, line: line)
            .animate()
            .fadeIn()
            .slideY(begin: 0.1, end: 0);
      }).toList(),
    );
  }
}
