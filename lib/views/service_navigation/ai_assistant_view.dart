import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/glass_card.dart';
import '../../core/theme.dart';
import '../../providers/civic_provider.dart';
import '../../models/recommendation.dart';

class AIAssistantView extends ConsumerStatefulWidget {
  const AIAssistantView({super.key});

  @override
  ConsumerState<AIAssistantView> createState() => _AIAssistantViewState();
}

class _AIAssistantViewState extends ConsumerState<AIAssistantView> {
  final _controller = TextEditingController();

  void _submitQuery() {
    if (_controller.text.trim().isNotEmpty) {
      ref.read(guidanceControllerProvider).getGuidance(_controller.text.trim());
      _controller.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final guidanceState = ref.watch(guidanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Civic Guide'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildResponseArea(guidanceState),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildResponseArea(AsyncValue<Recommendation?> state) {
    return state.when(
      data: (rec) {
        if (rec == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.bot, size: 64, color: AppTheme.primaryColor.withOpacity(0.5)),
                const SizedBox(height: 16),
                const Text(
                  'How can I help you today?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                  child: Text(
                    'Ask about passport renewal, flood assistance, or any public service.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white38),
                  ),
                ),
              ],
            ),
          );
        }
        return _RecommendationView(recommendation: rec);
      },
      loading: () => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Processing your request...'),
          ],
        ),
      ),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent)),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type your question...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onSubmitted: (_) => _submitQuery(),
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            mini: true,
            onPressed: _submitQuery,
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(LucideIcons.send, size: 20),
          ),
        ],
      ),
    );
  }
}

class _RecommendationView extends StatelessWidget {
  final Recommendation recommendation;

  const _RecommendationView({required this.recommendation});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        GlassCard(
          gradientColors: [
            AppTheme.primaryColor.withOpacity(0.2),
            AppTheme.secondaryColor.withOpacity(0.1),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    recommendation.isUrgent ? LucideIcons.alertTriangle : LucideIcons.info,
                    color: recommendation.isUrgent ? Colors.redAccent : AppTheme.accentColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    recommendation.agency,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                recommendation.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                recommendation.description,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ).animate().fadeIn().slideY(begin: 0.1),
        const SizedBox(height: 24),
        _buildSectionTitle('Required Steps'),
        const SizedBox(height: 12),
        ...recommendation.steps.asMap().entries.map((entry) {
          return _buildStepItem(entry.key + 1, entry.value);
        }),
        const SizedBox(height: 24),
        _buildSectionTitle('Required Documents'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: recommendation.requiredDocuments.map((doc) {
            return Chip(
              label: Text(doc, style: const TextStyle(fontSize: 12)),
              backgroundColor: Colors.white.withOpacity(0.05),
              side: BorderSide(color: Colors.white.withOpacity(0.1)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildStepItem(int num, String step) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
            child: Text(
              num.toString(),
              style: const TextStyle(fontSize: 12, color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(step)),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1);
  }
}
