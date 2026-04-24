import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/civic_provider.dart';
import '../../models/feedback_model.dart';

class FeedbackView extends ConsumerStatefulWidget {
  const FeedbackView({super.key});

  @override
  ConsumerState<FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends ConsumerState<FeedbackView> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  
  FeedbackCategory _selectedCategory = FeedbackCategory.suggestion;
  int _rating = 5;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final feedback = UserFeedback(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'user_123',
      category: _selectedCategory,
      subject: _subjectController.text,
      message: _messageController.text,
      rating: _rating,
      timestamp: DateTime.now(),
    );

    final success = await ref.read(feedbackProvider.notifier).submitFeedback(feedback);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        _showSuccessDialog();
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.checkCircle, color: Colors.greenAccent, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Thank You!',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your feedback has been submitted to our database and will help us improve MyCivicXpress.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Back to history
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Close', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ).animate().scale(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      appBar: AppBar(
        title: const Text('Give Feedback', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                'Help us improve the Civic Hub',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your voice matters. Let us know what you think about our services.',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 32),
              
              _buildLabel('Category'),
              const SizedBox(height: 8),
              _buildCategorySelector(),
              
              const SizedBox(height: 24),
              _buildLabel('Rating'),
              const SizedBox(height: 8),
              _buildRatingSelector(),
              
              const SizedBox(height: 24),
              _buildLabel('Subject'),
              const SizedBox(height: 8),
              _buildTextField(_subjectController, 'e.g. App crashing on load', 1),
              
              const SizedBox(height: 24),
              _buildLabel('Message'),
              const SizedBox(height: 8),
              _buildTextField(_messageController, 'Share your thoughts or report details here...', 5),
              
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSubmitting 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Submit Feedback',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<FeedbackCategory>(
          value: _selectedCategory,
          isExpanded: true,
          dropdownColor: const Color(0xFF1E293B),
          icon: const Icon(LucideIcons.chevronDown, color: Colors.white38),
          style: const TextStyle(color: Colors.white),
          items: FeedbackCategory.values.map((cat) {
            return DropdownMenuItem(
              value: cat,
              child: Text(cat.name.toUpperCase()),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedCategory = val);
          },
        ),
      ),
    );
  }

  Widget _buildRatingSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final isActive = _rating >= starIndex;
        return IconButton(
          onPressed: () => setState(() => _rating = starIndex),
          icon: Icon(
            LucideIcons.star,
            color: isActive ? Colors.amberAccent : Colors.white10,
            fill: isActive ? 1.0 : 0.0,
            size: 32,
          ),
        );
      }),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, int lines) {
    return TextFormField(
      controller: controller,
      maxLines: lines,
      style: const TextStyle(color: Colors.white),
      validator: (val) => val == null || val.isEmpty ? 'This field is required' : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
