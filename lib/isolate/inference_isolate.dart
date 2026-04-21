import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart' show rootBundle;
import 'package:submission/services/ml_service.dart';
import 'dart:typed_data';

Future<Map<String, dynamic>> runInference(String path) async {
  final image = img.decodeImage(File(path).readAsBytesSync());

  if (image == null) {
    throw Exception("Gagal membaca gambar");
  }

  final resized = img.copyResize(image, width: 224, height: 224);
  final input = _imageToTensor(resized);

  final ml = MLService();
  await ml.loadModel();

  final result = ml.run(input);

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
    throw Exception("Label tidak cocok dengan model");
  }

  return {
    "label": labels[maxIndex],
    "confidence": (maxScore * 100).toStringAsFixed(2),
  };
}

Future<List<String>> loadLabels() async {
  final data = await rootBundle.loadString('assets/labels.txt');

  return data.split('\n').map((line) {
    final parts = line.trim().split(' ');

    if (parts.length > 1) {
      return parts.sublist(1).join(' ');
    }

    return line.trim();
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

