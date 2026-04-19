import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
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

// Provider for Authentication State
final authStateProvider = StateProvider<bool>((ref) => false);

// Provider for App Language (EN, BM, CN, TN)
final languageProvider = StateProvider<String>((ref) => 'EN');

// Provider for Citizen Impact Score
final impactScoreProvider = StateProvider<int>((ref) => 1250); // Initial mock score

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
  final FirebaseService _firebase;
  
  CitizenProfileNotifier(this._firebase) : super(const CitizenProfile(
    fullName: 'Malaysian Citizen',
    icNumber: '000000-00-0000',
    dob: '',
    gender: '',
    location: 'Kuala Lumpur',
    address: '',
    isVerified: false,
  ));

  Future<bool> registerUser(CitizenProfile profile, String password) async {
    try {
      // Use email-style auth for Firebase using IC
      final email = "${profile.icNumber}@civicease.gov.my";
      final cred = await _firebase.signUp(email, password, profile);
      if (cred != null) {
        state = profile.copyWith(isVerified: true);
        return true;
      }
    } catch (e) {
      print('Registration Error: $e');
    }
    return false;
  }

  Future<bool> login(String icNumber, String password) async {
    try {
      final email = "$icNumber@civicease.gov.my";
      final cred = await _firebase.login(email, password);
      if (cred != null && cred.user != null) {
        final profile = await _firebase.getProfile(cred.user!.uid);
        if (profile != null) {
          state = profile;
          return true;
        }
      }
    } catch (e) {
      print('Login Error: $e');
    }
    return false;
  }

  Future<void> updateImpactScore(int points) async {
    await _firebase.updateImpactScore(points);
    state = state.copyWith(impactScore: state.impactScore + points);
  }

  Future<bool> updateProfile(CitizenProfile newProfile) async {
    // Simulate database network delay
    await Future.delayed(const Duration(seconds: 1));
    
    print('USER DATA UPDATED IN DATABASE: Name=${newProfile.name}, Location=${newProfile.location}');
    
    state = newProfile;
    return true;
  }
}

final citizenProfileProvider = StateNotifierProvider<CitizenProfileNotifier, CitizenProfile>((ref) {
  return CitizenProfileNotifier(ref.read(firebaseServiceProvider));
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
    
    // In a real app, this would be an HTTP POST to a database/API
    print('FEEDBACK SUBMITTED TO DATABASE: ${feedback.toJson()}');
    
    state = [feedback, ...state];
    return true;
  }
}

final feedbackProvider = StateNotifierProvider<FeedbackNotifier, List<UserFeedback>>((ref) {
  return FeedbackNotifier();
});

// Complaints Provider (Real-time Stream)
final complaintsStreamProvider = StreamProvider<List<CivicComplaint>>((ref) {
  return ref.read(firebaseServiceProvider).getMyComplaints();
});

class ComplaintsNotifier extends StateNotifier<List<CivicComplaint>> {
  final FirebaseService _firebase;
  ComplaintsNotifier(this._firebase) : super([]);

  Future<void> submitComplaint(CivicComplaint complaint) async {
    await _firebase.submitComplaint(complaint);
  }
}

final complaintsProvider = StateNotifierProvider<ComplaintsNotifier, List<CivicComplaint>>((ref) {
  return ComplaintsNotifier(ref.read(firebaseServiceProvider));
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
    }
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier(ref);
});

// Appointment Provider (Real-time Stream)
final appointmentStreamProvider = StreamProvider<CivicAppointment?>((ref) {
  return ref.read(firebaseServiceProvider).getLatestAppointment();
});

class AppointmentNotifier extends StateNotifier<CivicAppointment?> {
  final FirebaseService _firebase;
  AppointmentNotifier(this._firebase) : super(null);

  Future<void> bookAppointment(CivicAppointment appointment) async {
    await _firebase.bookAppointment(appointment);
  }
}

final appointmentProvider = StateNotifierProvider<AppointmentNotifier, CivicAppointment?>((ref) {
  return AppointmentNotifier(ref.read(firebaseServiceProvider));
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
          AsyncError('API Key not configured.', StackTrace.current);
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
