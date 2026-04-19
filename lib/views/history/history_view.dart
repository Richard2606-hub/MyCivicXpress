import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/glass_card.dart';
import '../../core/theme.dart';
import '../../providers/civic_provider.dart';
import '../../models/interaction_model.dart';
import '../../models/recommendation.dart';
import '../feedback/feedback_view.dart';

class CivicHistoryView extends ConsumerStatefulWidget {
  const CivicHistoryView({super.key});

  @override
  ConsumerState<CivicHistoryView> createState() => _CivicHistoryViewState();
}

class _CivicHistoryViewState extends ConsumerState<CivicHistoryView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      appBar: AppBar(
        title: const Text('Interaction History', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.messageSquarePlus, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackView()));
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF6366F1),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white38,
          tabs: const [
            Tab(text: 'All Activity'),
            Tab(text: 'AI Guide'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActivityFeed(),
          _buildAIHistory(),
        ],
      ),
    );
  }

  Widget _buildActivityFeed() {
    final activities = ref.watch(interactionHistoryProvider);

    if (activities.isEmpty) {
      return _buildEmptyState('No recent activity');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return _buildActivityItem(activity, index);
      },
    );
  }

  Widget _buildActivityItem(UserInteraction activity, int index) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: activity.color.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: activity.color.withOpacity(0.3)),
                ),
                child: Icon(activity.icon, size: 18, color: activity.color),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.subtitle,
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(activity.timestamp),
                    style: TextStyle(color: activity.color.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)).slideX(begin: 0.1, end: 0);
  }

  Widget _buildAIHistory() {
    final history = ref.watch(historyProvider);

    if (history.isEmpty) {
      return _buildEmptyState('No AI recommendations yet');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final rec = history[index];
        return _buildAIItem(rec, index);
      },
    );
  }

  Widget _buildAIItem(Recommendation rec, int index) {
    final typeColor = _getTypeColor(rec.type);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: InkWell(
          onTap: () => _showRecommendationDetail(context, rec),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(_getIconForType(rec.type), size: 20, color: typeColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rec.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      '${DateFormat('MMM dd').format(rec.timestamp)} • ${rec.agency}',
                      style: const TextStyle(fontSize: 12, color: Colors.white38),
                    ),
                  ],
                ),
              ),
              const Icon(LucideIcons.chevronRight, size: 16, color: Colors.white24),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)).slideY(begin: 0.2, end: 0);
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.history, size: 48, color: Colors.white10),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.white38)),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return DateFormat('h:mm a').format(timestamp);
  }

  Color _getTypeColor(RecommendationType type) {
    switch (type) {
      case RecommendationType.service: return const Color(0xFF6366F1);
      case RecommendationType.document: return const Color(0xFFEC4899);
      case RecommendationType.emergency: return Colors.redAccent;
      case RecommendationType.information: return Colors.blue;
      default: return Colors.grey;
    }
  }

  IconData _getIconForType(RecommendationType type) {
    switch (type) {
      case RecommendationType.service: return LucideIcons.briefcase;
      case RecommendationType.document: return LucideIcons.fileText;
      case RecommendationType.emergency: return LucideIcons.alertTriangle;
      default: return LucideIcons.info;
    }
  }

  void _showRecommendationDetail(BuildContext context, Recommendation rec) {
    // Re-use existing modal logic or expand here
  }
}
