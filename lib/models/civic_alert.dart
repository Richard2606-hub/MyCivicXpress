enum AlertSeverity { emergency, warning, info }
enum AlertCategory { transport, economy, traffic, weather, event, safety }

class CivicAlert {
  final String id;
  final String title;
  final String description;
  final String agency;
  final DateTime timestamp;
  final AlertSeverity severity;
  final AlertCategory category;
  final bool isInteractive;

  CivicAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.agency,
    required this.timestamp,
    required this.severity,
    required this.category,
    this.isInteractive = false,
  });
}
