import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/citizen_profile.dart';
import '../models/recommendation.dart';
import '../models/civic_alert.dart';
import '../models/interaction_model.dart';
import '../models/feedback_model.dart';
import '../models/govtech_models.dart';
import '../services/gemini_service.dart';
import '../services/firebase_service.dart';

// Provider for Navigation
final navigationProvider = StateProvider<int>((ref) => 0);

// Provider for Firebase Service
final firebaseServiceProvider = Provider((ref) => FirebaseService());

// Provider for Authentication State — persisted
class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier() : super(false) {
    _loadAuthState();
  }

  static const _key = 'civic_auth_state';

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? false;
  }

  Future<void> setLoggedIn(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }

  Future<void> logout() async {
    state = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, false);
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier();
});

// Provider for App Language (EN, BM, CN, TN)
final languageProvider = StateProvider<String>((ref) => 'EN');

// Provider for Citizen Impact Score — persisted
class ImpactScoreNotifier extends StateNotifier<int> {
  ImpactScoreNotifier() : super(1250) {
    _load();
  }

  static const _key = 'civic_impact_score';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt(_key) ?? 1250;
  }

  Future<void> add(int points) async {
    state = state + points;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, state);
  }

  Future<void> set(int value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, state);
  }
}

final impactScoreProvider = StateNotifierProvider<ImpactScoreNotifier, int>((ref) {
  return ImpactScoreNotifier();
});

// Provider for Civic Alerts
final alertsProvider = StateProvider<List<CivicAlert>>((ref) {
  return [
    CivicAlert(
      id: 'a1',
      title: 'Fuel Price Update (RON95)',
      description: 'The retail price of RON95 remains at RM2.05 per litre. Diesel price adjusted based on global trends.',
      agency: 'MOF Malaysia',
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      severity: AlertSeverity.info,
      category: AlertCategory.economy,
    ),
    CivicAlert(
      id: 'a2',
      title: 'LRT Kelana Jaya Line: 15min Delay',
      description: 'Technical issues at Bangsar station. Trains moving at slower speeds. Shuttle buses activated between KL Sentral and Abdullah Hukum.',
      agency: 'Rapid KL',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      severity: AlertSeverity.warning,
      category: AlertCategory.transport,
      isInteractive: true,
    ),
    CivicAlert(
      id: 'a3',
      title: 'Congestion on Federal Highway',
      description: 'Heavy traffic heading towards KL due to an accident at KM 12.5. Expect delays of 30 minutes.',
      agency: 'LLM / ITIS',
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      severity: AlertSeverity.warning,
      category: AlertCategory.traffic,
    ),
    CivicAlert(
      id: 'a4',
      title: 'Road Closure: Jalan Raja Laut',
      description: 'Closed for Merdeka Day rehearsal from 6:00 AM to 12:00 PM tomorrow. Please use alternative routes.',
      agency: 'DBKL',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      severity: AlertSeverity.info,
      category: AlertCategory.event,
    ),
    CivicAlert(
      id: 'a5',
      title: 'Flash Flood Warning',
      description: 'Heavy rain expected in Klang Valley. High risk of flash floods in Ampang and Cheras.',
      agency: 'NADMA',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      severity: AlertSeverity.emergency,
      category: AlertCategory.weather,
      isInteractive: true,
    ),
  ];
});

// Profile Notifier for persistence and DB simulation
class CitizenProfileNotifier extends StateNotifier<CitizenProfile> {
  CitizenProfileNotifier() : super(CitizenProfile.defaultProfile()) {
    _loadProfile();
  }

  static const _profileKey = 'civic_user_profile';

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileStr = prefs.getString(_profileKey);
    if (profileStr != null) {
      try {
        state = CitizenProfile.fromJsonString(profileStr);
      } catch (_) {
        // If corrupted, keep default
      }
    }
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, state.toJsonString());
  }

  Future<bool> registerUser(CitizenProfile profile) async {
    // Simulate JPN Identity Verification delay
    await Future.delayed(const Duration(seconds: 2));
    
    state = profile.copyWith(isVerified: true);
    await _saveProfile();
    return true;
  }

  Future<bool> login(String icNumber, String password) async {
    // Simulate auth check
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (icNumber.isNotEmpty && password.length >= 6) {
      // Try to load saved profile if IC matches
      final prefs = await SharedPreferences.getInstance();
      final profileStr = prefs.getString(_profileKey);
      if (profileStr != null) {
        try {
          final saved = CitizenProfile.fromJsonString(profileStr);
          // If a matching profile is found, use it
          if (saved.icNumber == icNumber || saved.id != 'guest') {
            state = saved;
          }
        } catch (_) {}
      }
      return true;
    }
    return false;
  }

  Future<bool> updateProfile(CitizenProfile newProfile) async {
    // Simulate database network delay
    await Future.delayed(const Duration(seconds: 1));
    
    state = newProfile;
    await _saveProfile();
    return true;
  }
}

final citizenProfileProvider = StateNotifierProvider<CitizenProfileNotifier, CitizenProfile>((ref) {
  return CitizenProfileNotifier();
});

// Provider for Gemini Service
final geminiServiceProvider = Provider<GeminiService?>((ref) {
  const apiKey = String.fromEnvironment('GEMINI_API_KEY');
  if (apiKey.isEmpty) return null;
  return GeminiService(apiKey);
});

// History Notifier for persistence
class HistoryNotifier extends StateNotifier<List<Recommendation>> {
  HistoryNotifier() : super([]) {
    _loadHistory();
  }

  static const _key = 'civic_history';

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    state = data
        .map((item) => Recommendation.fromJson(jsonDecode(item)))
        .toList();
  }

  Future<void> addRecommendation(Recommendation rec) async {
    state = [rec, ...state];
    final prefs = await SharedPreferences.getInstance();
    final data = state.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_key, data);
  }
  
  Future<void> clearHistory() async {
    state = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

final historyProvider = StateNotifierProvider<HistoryNotifier, List<Recommendation>>((ref) {
  return HistoryNotifier();
});

// Interaction History Notifier
class InteractionHistoryNotifier extends StateNotifier<List<UserInteraction>> {
  InteractionHistoryNotifier() : super([]) {
    _loadMockData();
  }

  void _loadMockData() {
    state = [
      UserInteraction(
        id: '1',
        title: 'Checked LRT Kelana Jaya',
        subtitle: 'Arrival times for KL Sentral',
        type: InteractionType.transitCheck,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        icon: LucideIcons.bus,
        color: Colors.pinkAccent,
      ),
      UserInteraction(
        id: '2',
        title: 'Asked AI Guide',
        subtitle: 'Analysis of fuel price updates',
        type: InteractionType.aiRequest,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        icon: LucideIcons.bot,
        color: Colors.greenAccent,
      ),
      UserInteraction(
        id: '3',
        title: 'Viewed Weather Map',
        subtitle: 'Checked Selangor weather',
        type: InteractionType.weatherCheck,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        icon: LucideIcons.cloudSun,
        color: Colors.cyanAccent,
      ),
      UserInteraction(
        id: '4',
        title: 'Searched for SK Utama',
        subtitle: 'Using School Suggester',
        type: InteractionType.search,
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        icon: LucideIcons.search,
        color: Colors.orangeAccent,
      ),
      UserInteraction(
        id: '5',
        title: 'Opened MyTax Portal',
        subtitle: 'From Active Services',
        type: InteractionType.click,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        icon: LucideIcons.mousePointer2,
        color: Colors.blueAccent,
      ),
    ];
  }

  void addInteraction(UserInteraction interaction) {
    state = [interaction, ...state];
  }
}

final interactionHistoryProvider = StateNotifierProvider<InteractionHistoryNotifier, List<UserInteraction>>((ref) {
  return InteractionHistoryNotifier();
});

// Feedback Provider
class FeedbackNotifier extends StateNotifier<List<UserFeedback>> {
  FeedbackNotifier() : super([]);

  Future<bool> submitFeedback(UserFeedback feedback) async {
    // Simulate network delay for database submission
    await Future.delayed(const Duration(seconds: 1));
    
    // Persist feedback to SharedPreferences
    state = [feedback, ...state];
    final prefs = await SharedPreferences.getInstance();
    final data = state.map((f) => jsonEncode(f.toJson())).toList();
    await prefs.setStringList('civic_feedback', data);
    return true;
  }
}

final feedbackProvider = StateNotifierProvider<FeedbackNotifier, List<UserFeedback>>((ref) {
  return FeedbackNotifier();
});

// Complaints Provider
class ComplaintsNotifier extends StateNotifier<List<CivicComplaint>> {
  ComplaintsNotifier() : super([]);

  Future<void> submitComplaint(CivicComplaint complaint) async {
    await Future.delayed(const Duration(seconds: 1));
    state = [complaint, ...state];
  }
}

final complaintsProvider = StateNotifierProvider<ComplaintsNotifier, List<CivicComplaint>>((ref) {
  return ComplaintsNotifier();
});

// Subsidy Provider
final subsidyProvider = Provider<List<GovtSubsidy>>((ref) {
  return [
    GovtSubsidy(
      name: 'STR (Sumbangan Tunai Rahmah)',
      description: 'Phase 3 distribution for B40 category.',
      amount: 600.0,
      isEligible: true,
      history: ['Phase 1: RM500 received', 'Phase 2: RM300 received'],
    ),
    GovtSubsidy(
      name: 'SARA (Asas Rahmah)',
      description: 'Monthly essential food allowance.',
      amount: 100.0,
      isEligible: true,
      history: ['July: RM100 spent at 99 Speedmart', 'June: RM100 spent at Lotus'],
    ),
    GovtSubsidy(
      name: 'e-Belia Rahmah',
      description: 'One-off credit for youth aged 18-20.',
      amount: 200.0,
      isEligible: false,
      history: ['Already claimed in 2023'],
    ),
  ];
});

// AI Chat Models
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, required this.timestamp});
}

// AI Chat Provider
class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final Ref _ref;
  ChatNotifier(this._ref) : super([
    ChatMessage(
      text: "Hello! I am your CivicEase AI Assistant. How can I help you today? You can ask me about passport renewals, MyKad updates, or available subsidies.",
      isUser: false,
      timestamp: DateTime.now(),
    )
  ]);

  Future<void> sendMessage(String text) async {
    state = [...state, ChatMessage(text: text, isUser: true, timestamp: DateTime.now())];
    
    final service = _ref.read(geminiServiceProvider);
    if (service != null) {
      try {
        final profile = _ref.read(citizenProfileProvider);
        final context = "User: ${profile.name}. Location: ${profile.location}. I am a Malaysian Government Assistant.";
        final response = await service.getCivicGuidance(text, context);
        state = [...state, ChatMessage(text: response.description, isUser: false, timestamp: DateTime.now())];
      } catch (e) {
        state = [...state, ChatMessage(text: "I'm sorry, I'm having trouble connecting to the civic servers. Please try again later.", isUser: false, timestamp: DateTime.now())];
      }
    } else {
      // No API key configured — provide a helpful fallback response
      state = [...state, ChatMessage(
        text: "Thank you for your query! The AI service is currently being configured. In the meantime, you can explore our services through the Dashboard — including Renewal Hub, Health Dashboard, Transit Hub, and more.",
        isUser: false, 
        timestamp: DateTime.now(),
      )];
    }
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier(ref);
});

// Appointment Model
class CivicAppointment {
  final String agency;
  final String date;
  final String time;
  final String queueNumber;
  final int estWaitTime;

  CivicAppointment({required this.agency, required this.date, required this.time, required this.queueNumber, required this.estWaitTime});

  Map<String, dynamic> toJson() => {
    'agency': agency,
    'date': date,
    'time': time,
    'queueNumber': queueNumber,
    'estWaitTime': estWaitTime,
  };

  // Firebase-compatible aliases
  Map<String, dynamic> toMap() => toJson();
  factory CivicAppointment.fromMap(Map<String, dynamic> map) => CivicAppointment.fromJson(map);

  factory CivicAppointment.fromJson(Map<String, dynamic> json) => CivicAppointment(
    agency: json['agency'],
    date: json['date'],
    time: json['time'],
    queueNumber: json['queueNumber'],
    estWaitTime: json['estWaitTime'],
  );
}

// Appointment Provider — persisted
class AppointmentNotifier extends StateNotifier<CivicAppointment?> {
  AppointmentNotifier() : super(null) {
    _load();
  }

  static const _key = 'civic_appointment';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data != null) {
      try {
        state = CivicAppointment.fromJson(jsonDecode(data));
      } catch (_) {}
    }
  }

  Future<void> setAppointment(CivicAppointment appointment) async {
    state = appointment;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(appointment.toJson()));
  }

  Future<void> clear() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

final appointmentProvider = StateNotifierProvider<AppointmentNotifier, CivicAppointment?>((ref) {
  return AppointmentNotifier();
});

// Simplified Guidance State
final guidanceProvider = StateProvider<AsyncValue<Recommendation?>>((ref) => const AsyncData(null));

// Dedicated controller for Guidance
class GuidanceController {
  final Ref _ref;
  GuidanceController(this._ref);

  Future<void> getGuidance(String query) async {
    final service = _ref.read(geminiServiceProvider);
    if (service == null) {
      _ref.read(guidanceProvider.notifier).state = 
          AsyncError('API Key not configured. Please run the app with --dart-define=GEMINI_API_KEY=your_key', StackTrace.current);
      return;
    }

    _ref.read(guidanceProvider.notifier).state = const AsyncLoading();
    
    try {
      final profile = _ref.read(citizenProfileProvider);
      final context = "User is in ${profile.location}. Interests: ${profile.interests.join(', ')}.";
      final rec = await service.getCivicGuidance(query, context);
      
      await _ref.read(historyProvider.notifier).addRecommendation(rec);
      _ref.read(guidanceProvider.notifier).state = AsyncData(rec);
    } catch (e, st) {
      _ref.read(guidanceProvider.notifier).state = AsyncError(e, st);
    }
  }
}

final guidanceControllerProvider = Provider((ref) => GuidanceController(ref));
