import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'ptptn_calculator_view.dart';
import 'course_directory_view.dart';
import 'school_suggester_view.dart';

class EducationHubView extends StatelessWidget {
  const EducationHubView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Education Hub', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Explore university courses and estimate your PTPTN loan eligibility.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ).animate().fadeIn().slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 40),
            
            _buildFeatureCard(
              context,
              title: 'PTPTN Estimator',
              description: 'Calculate your maximum loan based on income (B40, M40, T20).',
              icon: LucideIcons.calculator,
              color: const Color(0xFF6366F1), // Indigo
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PtptnCalculatorView())),
            ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1, end: 0),
            
            const SizedBox(height: 20),
            
            _buildFeatureCard(
              context,
              title: 'Course Directory',
              description: 'Browse top university courses, duration, and tuition fees.',
              icon: LucideIcons.library,
              color: const Color(0xFFE91E63), // Pink
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CourseDirectoryView())),
            ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1, end: 0),
            
            const SizedBox(height: 20),
            
            _buildFeatureCard(
              context,
              title: 'School Suggester',
              description: 'Find primary and secondary schools based on your location.',
              icon: LucideIcons.mapPin,
              color: const Color(0xFF4CAF50), // Green
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SchoolSuggesterView())),
            ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1, end: 0),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, {required String title, required String description, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}
