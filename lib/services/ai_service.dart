import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String apiKey =
  String.fromEnvironment('GEMINI_API_KEY');

  static const String endpoint =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash-lite:generateContent";

  Future<String> askCareerAI(String question) async {
    if (apiKey.isEmpty) {
      return "AI service is not configured. Please contact the administrator.";
    }

    // Retry 3 times if Gemini is busy
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        final response = await http.post(
          Uri.parse(endpoint),
          headers: {
            "Content-Type": "application/json",
            "x-goog-api-key": apiKey,
          },
          body: jsonEncode({
            "contents": [
              {
                "parts": [
                  {
                    "text":
                    "You are a career guidance assistant. Never introduce yourself. Answer in simple English within 100 words.\n\nQuestion: $question"
                  }
                ]
              }
            ],
            "generationConfig": {
              "temperature": 0.3,
              "maxOutputTokens": 150,
            },
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          return data["candidates"][0]["content"]["parts"][0]["text"];
        }

        // Retry only for 503
        if (response.statusCode == 503 && attempt < 3) {
          await Future.delayed(
            Duration(seconds: attempt * 2),
          );
          continue;
        }

        final error = jsonDecode(response.body);

        return "API Error ${response.statusCode}\n${error["error"]["message"]}";
      } catch (e) {
        if (attempt == 3) {
          return "Connection Error\n$e";
        }

        await Future.delayed(
          Duration(seconds: attempt * 2),
        );
      }
    }

    return "Gemini server is busy. Please try again.";
  }
}