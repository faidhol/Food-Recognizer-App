import 'dart:convert';
import 'package:http/http.dart' as http;

class MealService {
  Future<Map<String, dynamic>?> fetchMeal(String name) async {
    final url = Uri.parse(
      "https://www.themealdb.com/api/json/v1/1/search.php?s=$name",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['meals'] != null) {
        return data['meals'][0];
      }
    }

    return null;
  }
}
