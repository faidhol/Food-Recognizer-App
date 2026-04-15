import 'dart:io';
import 'package:flutter/material.dart';
import 'package:submission/isolate/inference_isolate.dart';
import 'package:submission/widget/classification_item.dart';
import 'package:submission/services/meal_service.dart';
import 'package:submission/services/gemini_service.dart';

class ResultPage extends StatelessWidget {
  final File image;

  const ResultPage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result Page'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(child: _ResultBody(image: image)),
    );
  }
}

class _ResultBody extends StatefulWidget {
  final File image;

  const _ResultBody({required this.image});

  @override
  State<_ResultBody> createState() => _ResultBodyState();
}

class _ResultBodyState extends State<_ResultBody> {
  String? label;
  String? confidence;
  bool isLoading = true;
  bool isError = false;

  Map<String, dynamic>? mealData;
  Map<String, String>? nutrition;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
  try {
    final result = await runInference(widget.image.path);

    Map<String, dynamic>? meal;
    Map<String, String>? nutri;

    try {
      meal = await MealService().fetchMeal(result['label']);
    } catch (e) {
      debugPrint("Meal API error: $e");
    }

    try {
      nutri = await GeminiService().getNutrition(result['label']);
    } catch (e) {
      debugPrint("Gemini error: $e");
    }

    if (!mounted) return;

    setState(() {
      label = result['label'];
      confidence = result['confidence'];
      mealData = meal;
      nutrition = nutri;
      isLoading = false;
      isError = false;
    });
  } catch (e, stack) {
    debugPrint("ERROR: $e");
    debugPrint("STACK: $stack");

    if (!mounted) return;

    setState(() {
      isLoading = false;
      isError = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}

  List<Widget> _buildIngredients(Map<String, dynamic> meal) {
    List<Widget> list = [];

    for (int i = 1; i <= 20; i++) {
      final ingredient = meal['strIngredient$i'];
      final measure = meal['strMeasure$i'];

      if (ingredient != null && ingredient != "") {
        list.add(Text("- $ingredient ($measure)"));
      }
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// IMAGE
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(widget.image, fit: BoxFit.cover),
                ),

                const SizedBox(height: 16),

                if (isLoading) const Center(child: CircularProgressIndicator()),

                if (isError)
                  Center(
                    child: Column(
                      children: [
                        const Text("Terjadi kesalahan"),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isLoading = true;
                              isError = false;
                            });
                            _loadData();
                          },
                          child: const Text("Coba Lagi"),
                        ),
                      ],
                    ),
                  ),

                if (!isLoading && !isError) ...[
                  ClassificationItem(
                    item: label ?? "-",
                    value: "${confidence ?? "-"}%",
                  ),

                  const SizedBox(height: 16),

                  if (mealData != null) ...[
                    Text(
                      mealData!['strMeal'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    if (mealData?['strMealThumb'] != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(mealData!['strMealThumb']),
                      ),

                    const SizedBox(height: 10),

                    const Text(
                      "Bahan:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    ..._buildIngredients(mealData!),

                    const SizedBox(height: 10),

                    const Text(
                      "Cara Memasak:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    Text(
                      mealData!['strInstructions'],
                      textAlign: TextAlign.justify,
                    ),
                  ] else
                    const Text("Resep tidak ditemukan"),

                  const SizedBox(height: 16),

                  if (nutrition != null) ...[
                    const Text(
                      "Informasi Nutrisi",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text("Kalori: ${nutrition!['kalori']}"),
                    Text("Protein: ${nutrition!['protein']}"),
                    Text("Lemak: ${nutrition!['lemak']}"),
                    Text("Karbohidrat: ${nutrition!['karbohidrat']}"),
                    Text("Serat: ${nutrition!['serat']}"),
                  ],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
