import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/education_model.dart';

class CourseDirectoryView extends StatefulWidget {
  const CourseDirectoryView({super.key});

  @override
  State<CourseDirectoryView> createState() => _CourseDirectoryViewState();
}

class _CourseDirectoryViewState extends State<CourseDirectoryView> {
  final List<UniversityCourse> _allCourses = UniversityCourse.getMockCourses();
  List<UniversityCourse> _filteredCourses = [];
  String _searchQuery = '';
  
  // Filters
  String _selectedLevel = 'All';
  String _selectedType = 'All';

  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'ms_MY', symbol: 'RM ');

  @override
  void initState() {
    super.initState();
    _filteredCourses = _allCourses;
  }

  void _applyFilters() {
    setState(() {
      _filteredCourses = _allCourses.where((course) {
        final matchesSearch = course.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                              course.university.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesLevel = _selectedLevel == 'All' || course.level == _selectedLevel;
        final matchesType = _selectedType == 'All' || course.type == _selectedType;
        
        return matchesSearch && matchesLevel && matchesType;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Course Directory', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search courses or universities...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon: const Icon(LucideIcons.search, color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    _searchQuery = value;
                    _applyFilters();
                  },
                ),
                const SizedBox(height: 16),
                
                // Filters Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All Levels', _selectedLevel == 'All', () {
                        _selectedLevel = 'All';
                        _applyFilters();
                      }),
                      _buildFilterChip('Degree', _selectedLevel == 'Degree', () {
                        _selectedLevel = 'Degree';
                        _applyFilters();
                      }),
                      _buildFilterChip('Diploma', _selectedLevel == 'Diploma', () {
                        _selectedLevel = 'Diploma';
                        _applyFilters();
                      }),
                      Container(width: 1, height: 24, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 8)),
                      _buildFilterChip('Public', _selectedType == 'Public', () {
                        _selectedType = 'Public';
                        _applyFilters();
                      }),
                      _buildFilterChip('Private', _selectedType == 'Private', () {
                        _selectedType = 'Private';
                        _applyFilters();
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: _filteredCourses.isEmpty
                ? const Center(child: Text('No courses found.', style: TextStyle(color: Colors.white54)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filteredCourses.length,
                    itemBuilder: (context, index) {
                      final course = _filteredCourses[index];
                      return _buildCourseCard(course).animate().fadeIn(delay: Duration(milliseconds: 50 * index)).slideX(begin: 0.1, end: 0);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.1)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildCourseCard(UniversityCourse course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  course.name,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: course.type == 'Public' ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  course.type,
                  style: TextStyle(
                    color: course.type == 'Public' ? Colors.greenAccent : Colors.orangeAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(LucideIcons.building, color: Colors.white54, size: 16),
              const SizedBox(width: 8),
              Text(course.university, style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailItem(LucideIcons.graduationCap, course.level),
              _buildDetailItem(LucideIcons.clock, '${course.durationYears} Years'),
              _buildDetailItem(LucideIcons.banknote, _currencyFormat.format(course.estimatedFee)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final url = Uri.parse(course.websiteUrl);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(LucideIcons.globe, size: 16, color: Colors.blueAccent),
              label: const Text('Visit Official Website', style: TextStyle(color: Colors.blueAccent)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.blueAccent.withOpacity(0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6366F1), size: 14),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
