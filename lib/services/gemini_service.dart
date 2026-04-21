import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: 'AIzaSyD8GQr0pryHl2slb6EzwZhPcElrZWVn-iU',
  );

  Future<Map<String, String>> getNutrition(String foodName) async {
    final prompt = """
Nama makanannya adalah $foodName.

Berikan estimasi kandungan nutrisi dalam format JSON:
{
  "kalori": "...",
  "protein": "...",
  "lemak": "...",
  "karbohidrat": "...",
  "serat": "..."
}
""";

    final response = await model.generateContent([Content.text(prompt)]);

    final text = response.text ?? "";

    return _parseNutrition(text);
  }

  Map<String, String> _parseNutrition(String text) {
    return {
      "kalori": _extract(text, "kalori"),
      "protein": _extract(text, "protein"),
      "lemak": _extract(text, "lemak"),
      "karbohidrat": _extract(text, "karbohidrat"),
      "serat": _extract(text, "serat"),
    };
  }

  String _extract(String text, String key) {
    final regex = RegExp('$key\\s*[:=]\\s*"?([^",}]*)');
    final match = regex.firstMatch(text.toLowerCase());
    return match?.group(1) ?? "-";
  }
}
