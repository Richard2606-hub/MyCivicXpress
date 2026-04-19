enum FeedbackCategory { bug, suggestion, praise, complaint, other }

class UserFeedback {
  final String id;
  final String userId;
  final FeedbackCategory category;
  final String subject;
  final String message;
  final int rating; // 1-5
  final DateTime timestamp;

  UserFeedback({
    required this.id,
    required this.userId,
    required this.category,
    required this.subject,
    required this.message,
    required this.rating,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'category': category.index,
      'subject': subject,
      'message': message,
      'rating': rating,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
