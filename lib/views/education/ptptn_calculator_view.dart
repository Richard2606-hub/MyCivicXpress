import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../models/education_model.dart';

class PtptnCalculatorView extends StatefulWidget {
  const PtptnCalculatorView({super.key});

  @override
  State<PtptnCalculatorView> createState() => _PtptnCalculatorViewState();
}

class _PtptnCalculatorViewState extends State<PtptnCalculatorView> {
  String _incomeTier = 'B40';
  String _institutionType = 'Public';
  String _levelOfStudy = 'Degree';
  double _calculatedAmount = 6500;

  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'ms_MY', symbol: 'RM ');

  void _recalculate() {
    setState(() {
      _calculatedAmount = PtptnLogic.calculateLoan(
        incomeTier: _incomeTier,
        institutionType: _institutionType,
        levelOfStudy: _levelOfStudy,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _recalculate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('PTPTN Estimator', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildResultCard(),
            const SizedBox(height: 40),
            
            const Text('Household Income', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildSegmentedControl(
              options: ['B40', 'M40', 'T20'],
              currentValue: _incomeTier,
              onChanged: (val) {
                _incomeTier = val;
                _recalculate();
              },
            ),
            
            const SizedBox(height: 24),
            const Text('Institution Type', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildSegmentedControl(
              options: ['Public', 'Private'],
              currentValue: _institutionType,
              onChanged: (val) {
                _institutionType = val;
                _recalculate();
              },
            ),
            
            const SizedBox(height: 24),
            const Text('Level of Study', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildSegmentedControl(
              options: ['Diploma', 'Degree'],
              currentValue: _levelOfStudy,
              onChanged: (val) {
                _levelOfStudy = val;
                _recalculate();
              },
            ),
            
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.info, color: Colors.blueAccent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'B40 receives maximum loan, M40 receives 75%, and T20 receives 50%. Actual amounts may vary based on specific PTPTN approvals.',
                      style: TextStyle(color: Colors.blueAccent.withValues(alpha: 0.8), fontSize: 12),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(LucideIcons.graduationCap, color: Colors.white, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Estimated Maximum Loan',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '${_currencyFormat.format(_calculatedAmount)} / year',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ).animate(key: ValueKey(_calculatedAmount)).scale(duration: 200.ms, curve: Curves.easeOutBack),
        ],
      ),
    ).animate().slideY(begin: -0.1, end: 0).fadeIn();
  }

  Widget _buildSegmentedControl({
    required List<String> options,
    required String currentValue,
    required Function(String) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: options.map((option) {
          final isSelected = option == currentValue;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(option),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4)]
                      : [],
                ),
                child: Center(
                  child: Text(
                    option,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white54,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
