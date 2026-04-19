enum RecommendationType { service, document, emergency, information }

class Recommendation {
  final String id;
  final String title;
  final String description;
  final List<String> steps;
  final List<String> requiredDocuments;
  final RecommendationType type;
  final DateTime timestamp;
  final String agency; // e.g., 'JPN', 'JPJ', 'NADMA'
  final bool isUrgent;

  Recommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.steps,
    required this.requiredDocuments,
    required this.type,
    required this.timestamp,
    this.agency = 'General',
    this.isUrgent = false,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'] ?? DateTime.now().toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      steps: List<String>.from(json['steps'] ?? []),
      requiredDocuments: List<String>.from(json['requiredDocuments'] ?? []),
      type: RecommendationType.values.firstWhere(
        (e) => e.name == (json['type'] ?? 'information'),
        orElse: () => RecommendationType.information,
      ),
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
      agency: json['agency'] ?? 'General',
      isUrgent: json['isUrgent'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'steps': steps,
      'requiredDocuments': requiredDocuments,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'agency': agency,
      'isUrgent': isUrgent,
    };
  }
}
