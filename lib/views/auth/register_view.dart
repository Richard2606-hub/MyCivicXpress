import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/civic_provider.dart';
import '../../models/citizen_profile.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/fancy_background.dart';

class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _icController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  
  String _selectedGender = 'Male';
  String _selectedState = 'Kuala Lumpur';
  bool _isLoading = false;

  final List<String> _malaysianStates = [
    'Kuala Lumpur', 'Selangor', 'Johor', 'Penang', 'Perak', 'Pahang', 'Negeri Sembilan', 
    'Melaka', 'Terengganu', 'Kelantan', 'Kedah', 'Perlis', 'Sabah', 'Sarawak', 'Putrajaya', 'Labuan'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _icController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final profile = CitizenProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      icNumber: _icController.text,
      dateOfBirth: _dobController.text,
      gender: _selectedGender,
      location: _selectedState,
      address: _addressController.text,
      interests: ['Public Transport', 'Health'],
      isVerified: true,
    );

    final success = await ref.read(citizenProfileProvider.notifier).registerUser(profile);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ref.read(authStateProvider.notifier).setLoggedIn(true);
        Navigator.pop(context); // Back to login, which will auto-switch to dashboard
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FancyBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('MyKad Registration'),
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Register Your Identity',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ).animate().fadeIn(),
                const Text(
                  'Please provide information as per your official MyKad.',
                  style: TextStyle(color: Colors.white60, fontSize: 14),
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 32),
                
                GlassCard(
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        label: 'Full Name (As per IC)',
                        icon: LucideIcons.user,
                        hint: 'e.g. MOHAMMAD BIN ALI',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _icController,
                        label: 'IC Number',
                        icon: LucideIcons.creditCard,
                        hint: '900101-14-5566',
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _dobController,
                              label: 'Date of Birth',
                              icon: LucideIcons.calendar,
                              hint: 'YYYY-MM-DD',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: _buildGenderDropdown()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildStateDropdown(),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _addressController,
                        label: 'Home Address',
                        icon: LucideIcons.home,
                        hint: 'Full residential address',
                        maxLines: 2,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _isLoading
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                                    SizedBox(width: 12),
                                    Text('Verifying with JPN...', style: TextStyle(color: Colors.white, fontSize: 14)),
                                  ],
                                )
                              : const Text(
                                  'Register & Verify',
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
            prefixIcon: Icon(icon, color: Colors.white54, size: 18),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gender', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedGender,
              isExpanded: true,
              dropdownColor: const Color(0xFF0F172A),
              style: const TextStyle(color: Colors.white),
              items: ['Male', 'Female'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (val) => setState(() => _selectedGender = val!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStateDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('State of Residence', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedState,
              isExpanded: true,
              dropdownColor: const Color(0xFF0F172A),
              style: const TextStyle(color: Colors.white),
              items: _malaysianStates.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => _selectedState = val!),
            ),
          ),
        ),
      ],
    );
  }
}
