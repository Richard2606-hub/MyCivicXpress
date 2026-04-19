import 'package:flutter/material.dart';

// Complaint Model
enum ComplaintStatus { pending, inProgress, resolved }

class CivicComplaint {
  final String id;
  final String category;
  final String description;
  final String location;
  final String council;
  final ComplaintStatus status;
  final DateTime timestamp;
  final String? imageUrl;
  final String? userId; // Link to the user who reported it

  CivicComplaint({
    required this.id,
    required this.category,
    required this.description,
    required this.location,
    required this.council,
    this.status = ComplaintStatus.pending,
    required this.timestamp,
    this.imageUrl,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'description': description,
      'location': location,
      'council': council,
      'status': status.index,
      'timestamp': timestamp.toIso8601String(),
      'imageUrl': imageUrl,
      'userId': userId,
    };
  }

  factory CivicComplaint.fromMap(Map<String, dynamic> map) {
    return CivicComplaint(
      id: map['id'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      council: map['council'] ?? '',
      status: ComplaintStatus.values[map['status'] ?? 0],
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      imageUrl: map['imageUrl'],
      userId: map['userId'],
    );
  }
}

// Appointment Model
class CivicAppointment {
  final String agency;
  final String date;
  final String time;
  final String queueNumber;
  final int estWaitTime;
  final String? userId;

  CivicAppointment({
    required this.agency,
    required this.date,
    required this.time,
    required this.queueNumber,
    required this.estWaitTime,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'agency': agency,
      'date': date,
      'time': time,
      'queueNumber': queueNumber,
      'estWaitTime': estWaitTime,
      'userId': userId,
    };
  }

  factory CivicAppointment.fromMap(Map<String, dynamic> map) {
    return CivicAppointment(
      agency: map['agency'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      queueNumber: map['queueNumber'] ?? '',
      estWaitTime: map['estWaitTime'] ?? 0,
      userId: map['userId'],
    );
  }
}

// AI Chat Model
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, required this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      text: map['text'] ?? '',
      isUser: map['isUser'] ?? false,
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

// Subsidy Model
class GovtSubsidy {
  final String name;
  final String description;
  final double amount;
  final bool isEligible;
  final List<String> history;

  GovtSubsidy({
    required this.name,
    required this.description,
    required this.amount,
    required this.isEligible,
    required this.history,
  });
}

// Translation Helper
class AppTranslation {
  static const Map<String, Map<String, String>> strings = {
    'EN': {
      'welcome': 'Welcome back,',
      'quick_actions': 'Services Hub',
      'active_services': 'Active Services',
      'sos': 'EMERGENCY SOS',
      'digital_id': 'Digital MyKad ID',
      'subsidy': 'Welfare & Subsidies',
      'complaints': 'Smart Complaints',
      'citizen_score': 'Citizen Impact Score',
    },
    'BM': {
      'welcome': 'Selamat kembali,',
      'quick_actions': 'Hab Perkhidmatan',
      'active_services': 'Perkhidmatan Aktif',
      'sos': 'SOS KECEMASAN',
      'digital_id': 'ID MyKad Digital',
      'subsidy': 'Kebajikan & Subsidi',
      'complaints': 'Aduan Pintar',
      'citizen_score': 'Skor Impak Rakyat',
    },
    'CN': {
      'welcome': '欢迎回来,',
      'quick_actions': '服务中心',
      'active_services': '正在运行的服务',
      'sos': '紧急求助',
      'digital_id': '数字身份证',
      'subsidy': '福利与补贴',
      'complaints': '智能投诉',
      'citizen_score': '公民贡献分',
    },
    'TN': {
      'welcome': 'மீண்டும் வருக,',
      'quick_actions': 'சேவை மையம்',
      'active_services': 'செயலில் உள்ள சேவைகள்',
      'sos': 'அவசர உதவி',
      'digital_id': 'டிஜிட்டல் அடையாள அட்டை',
      'subsidy': 'நலன்புரி & மானியங்கள்',
      'complaints': 'ஸ்மார்ட் புகார்கள்',
      'citizen_score': 'குடிமக்கள் பங்களிப்பு மதிப்பெண்',
    },
  };
}
