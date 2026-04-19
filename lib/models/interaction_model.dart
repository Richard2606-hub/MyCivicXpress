import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

enum InteractionType { click, browse, search, aiRequest, transitCheck, weatherCheck }

class UserInteraction {
  final String id;
  final String title;
  final String subtitle;
  final InteractionType type;
  final DateTime timestamp;
  final IconData icon;
  final Color color;

  UserInteraction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.timestamp,
    required this.icon,
    required this.color,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'type': type.index,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory UserInteraction.fromJson(Map<String, dynamic> json) {
    final type = InteractionType.values[json['type']];
    return UserInteraction(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      type: type,
      timestamp: DateTime.parse(json['timestamp']),
      icon: _getIcon(type),
      color: _getColor(type),
    );
  }

  static IconData _getIcon(InteractionType type) {
    switch (type) {
      case InteractionType.click: return LucideIcons.mousePointer2;
      case InteractionType.browse: return LucideIcons.layoutGrid;
      case InteractionType.search: return LucideIcons.search;
      case InteractionType.aiRequest: return LucideIcons.bot;
      case InteractionType.transitCheck: return LucideIcons.bus;
      case InteractionType.weatherCheck: return LucideIcons.cloudSun;
    }
  }

  static Color _getColor(InteractionType type) {
    switch (type) {
      case InteractionType.click: return Colors.blueAccent;
      case InteractionType.browse: return Colors.purpleAccent;
      case InteractionType.search: return Colors.orangeAccent;
      case InteractionType.aiRequest: return Colors.greenAccent;
      case InteractionType.transitCheck: return Colors.pinkAccent;
      case InteractionType.weatherCheck: return Colors.cyanAccent;
    }
  }
}
