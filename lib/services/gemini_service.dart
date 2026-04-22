import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  GenerativeModel _createModel() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception("API KEY belum di-load dari .env");
    }

    return GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
  }

  Future<Map<String, String>> getNutrition(String foodName) async {
    final model = _createModel(); // 🔥 dibuat setelah env ready

    final prompt = """
Nama makanan: $foodName

Berikan estimasi kandungan nutrisi dalam format JSON VALID TANPA PENJELASAN:
{
  "kalori": "...",
  "protein": "...",
  "lemak": "...",
  "karbohidrat": "...",
  "serat": "..."
}
""";

    final response = await model.generateContent(
      [Content.text(prompt)],
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );

    final text = response.text ?? "{}";

    try {
      final jsonData = jsonDecode(text);

      return {
        "kalori": jsonData["kalori"] ?? "-",
        "protein": jsonData["protein"] ?? "-",
        "lemak": jsonData["lemak"] ?? "-",
        "karbohidrat": jsonData["karbohidrat"] ?? "-",
        "serat": jsonData["serat"] ?? "-",
      };
    } catch (e) {
      return {
        "kalori": "-",
        "protein": "-",
        "lemak": "-",
        "karbohidrat": "-",
        "serat": "-",
      };
    }
  }
}
