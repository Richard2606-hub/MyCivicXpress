import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/recommendation.dart';

class GeminiService {
  static const _modelName = 'gemini-2.0-flash';
  final GenerativeModel _model;

  GeminiService(String apiKey)
      : _model = GenerativeModel(
          model: _modelName,
          apiKey: apiKey,
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
          ),
        );

  Future<Recommendation> getCivicGuidance(String userQuery, String userContext) async {
    final prompt = '''
You are MyCivicXpress AI, an expert agentic assistant for navigating public services in Malaysia.
Your goal is to provide actionable, step-by-step guidance for citizens.

User Context: $userContext
User Query: $userQuery

Public Service Context:
- JPN (Jabatan Pendaftaran Negara): MyKad, birth certs, marriage.
- JPJ (Jabatan Pengangkutan Jalan): Driving licenses, road tax.
- KWSP (EPF): Retirement savings, withdrawals.
- Immigration: Passports, visas.
- LHDN: Taxes.
- NADMA: Emergency/disaster management (floods).

Guidelines:
1. Be specific and accurate about Malaysian government procedures.
2. If documents are needed, list them clearly.
3. Provide logical, sequential steps.
4. If it's an emergency (like flood assistance), set isUrgent to true and type to 'emergency'.

Return ONLY a valid JSON object in this format:
{
  "title": "Clear action title (e.g., Renewing Your MyKad)",
  "description": "Short summary of the process and what to expect.",
  "steps": ["Step 1: ...", "Step 2: ..."],
  "requiredDocuments": ["Document A", "Document B"],
  "type": "service" | "document" | "emergency" | "information",
  "agency": "e.g., JPN / JPJ / Immigration",
  "isUrgent": true | false
}
''';

    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    
    if (response.text == null) {
      throw Exception('Failed to generate recommendation');
    }

    final data = jsonDecode(response.text!);
    return Recommendation.fromJson(data);
  }
}
