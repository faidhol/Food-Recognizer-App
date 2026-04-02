import 'dart:io';
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

  return {
    "label": labels[maxIndex],
    "confidence": (maxScore * 100).toStringAsFixed(2),
  };
}

Future<List<String>> loadLabels() async {
  final data = await rootBundle.loadString('assets/label.txt');

  return data.split('\n').map((line) {
    final parts = line.trim().split(' ');

    if (parts.length > 1) {
      return parts.sublist(1).join(' ');
    }

    return line.trim();
  }).toList();
}

List<List<List<List<double>>>> _imageToTensor(img.Image image) {
  return [
    List.generate(224, (y) {
      return List.generate(224, (x) {
        final pixel = image.getPixel(x, y);

        return [
          pixel.r / 255.0,
          pixel.g / 255.0,
          pixel.b / 255.0,
        ];
      });
    }),
  ];
}