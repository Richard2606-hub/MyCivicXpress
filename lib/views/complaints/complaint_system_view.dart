import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/civic_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/fancy_background.dart';
import '../../models/govtech_models.dart';

class ComplaintSystemView extends ConsumerStatefulWidget {
  const ComplaintSystemView({super.key});

  @override
  ConsumerState<ComplaintSystemView> createState() => _ComplaintSystemViewState();
}

class _ComplaintSystemViewState extends ConsumerState<ComplaintSystemView> {
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Potholes';
  String _selectedCouncil = 'DBKL (Kuala Lumpur)';
  bool _isAnalyzing = false;
  bool _showSuccess = false;

  final List<String> _categories = ['Potholes', 'Street Lighting', 'Illegal Dumping', 'Broken Pipes', 'Fallen Trees'];
  final List<String> _councils = ['DBKL (Kuala Lumpur)', 'MBPJ (Petaling Jaya)', 'MBSJ (Subang Jaya)', 'MPK (Klang)'];

  Future<void> _submitReport() async {
    setState(() => _isAnalyzing = true);
    
    // Simulate AI Image Analysis
    await Future.delayed(const Duration(seconds: 2));
    
    final complaint = CivicComplaint(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: _selectedCategory,
      description: _descriptionController.text,
      location: 'Jalan Sultan Ismail, KL',
      council: _selectedCouncil,
      timestamp: DateTime.now(),
    );

    await ref.read(complaintsProvider.notifier).submitComplaint(complaint);
    
    // Increment Citizen Score
    ref.read(impactScoreProvider.notifier).state += 50;

    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        _showSuccess = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSuccess) return _buildSuccessState();

    return FancyBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Smart Complaints'),
          backgroundColor: Colors.transparent,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Report an Issue',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text(
                'AI will automatically tag your location and identify the category.',
                style: TextStyle(color: Colors.white60, fontSize: 14),
              ),
              const SizedBox(height: 32),
              _buildImageUploadPlaceholder(),
              const SizedBox(height: 24),
              _buildDropdown('Category', _selectedCategory, _categories, (val) => setState(() => _selectedCategory = val!)),
              const SizedBox(height: 16),
              _buildDropdown('Local Council', _selectedCouncil, _councils, (val) => setState(() => _selectedCouncil = val!)),
              const SizedBox(height: 16),
              const Text('Description', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Describe the issue...',
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadPlaceholder() {
    return GestureDetector(
      onTap: () {},
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            children: [
              Icon(LucideIcons.camera, color: AppTheme.accentColor, size: 40),
              const SizedBox(height: 16),
              const Text('Tap to Upload Photo', style: TextStyle(color: Colors.white70)),
              const Text('AI will analyze the photo instantly', style: TextStyle(color: Colors.white24, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF0F172A),
              style: const TextStyle(color: Colors.white),
              items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isAnalyzing ? null : _submitReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isAnalyzing 
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                SizedBox(width: 16),
                Text('AI Analysis in progress...', style: TextStyle(color: Colors.white)),
              ],
            )
          : const Text('Submit Report', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSuccessState() {
    return FancyBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.checkCircle, color: Colors.greenAccent, size: 80).animate().scale(),
                const SizedBox(height: 24),
                const Text(
                  'Report Submitted!',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your report has been sent to the Local Council. You earned +50 Citizen Impact Score!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back to Dashboard'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
