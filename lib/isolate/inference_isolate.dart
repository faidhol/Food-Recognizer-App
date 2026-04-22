import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart' show rootBundle;
import 'package:submission/services/ml_service.dart';

Future<Map<String, dynamic>> runInference(String path) async {
  final image = img.decodeImage(File(path).readAsBytesSync());

  if (image == null) {
    throw Exception("Gagal membaca gambar");
  }

  final resized = img.copyResize(image, width: 224, height: 224);
  final input = _imageToTensor(resized);

  final result = MLService().run(input);

  int maxIndex = 0;
  double maxScore = result[0];

  for (int i = 1; i < result.length; i++) {
    if (result[i] > maxScore) {
      maxScore = result[i];
      maxIndex = i;
    }
  }

  final labels = await loadLabels();

  if (maxIndex >= labels.length) {
    throw Exception("Index label tidak valid");
  }

  final rawLabel = labels[maxIndex].toLowerCase();

  const allowedFoods = [
    "pizza",
    "burger",
    "fried rice",
    "nasi lemak",
    "sushi",
    "ramen",
  ];

  String finalLabel = "Tidak dikenali";

  for (var food in allowedFoods) {
    if (rawLabel.contains(food)) {
      finalLabel = food;
      break;
    }
  }

  if (maxScore < 0.5) {
    return {"label": "Tidak dikenali", "confidence": "0"};
  }

  return {
    "label": finalLabel,
    "confidence": (maxScore * 100).toStringAsFixed(2),
  };
}

Future<List<String>> loadLabels() async {
  final data = await rootBundle.loadString('assets/labels.txt');

  return data.split('\n').map((line) {
    line = line.trim();

    if (line.isEmpty) return "";

    final parts = line.split(' ');

    if (parts.length > 1 && int.tryParse(parts[0]) != null) {
      return parts.sublist(1).join(' ');
    }

    return line;
  }).toList();
}

Uint8List _imageToTensor(img.Image image) {
  final buffer = Uint8List(224 * 224 * 3);

  int index = 0;

  for (int y = 0; y < 224; y++) {
    for (int x = 0; x < 224; x++) {
      final pixel = image.getPixel(x, y);

      buffer[index++] = pixel.r.toInt();
      buffer[index++] = pixel.g.toInt();
      buffer[index++] = pixel.b.toInt();
    }
  }

  return buffer;
}
