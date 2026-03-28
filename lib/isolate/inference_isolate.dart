import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:submission/services/ml_service.dart';

const List<String> labels = [
  "pizza",
  "burger",
  "fried rice",
  "sushi",
  "ramen",
];

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

  if (maxIndex >= labels.length) {
    throw Exception("Label tidak sesuai dengan model output");
  }

  return {
    "label": labels[maxIndex],
    "confidence": (maxScore * 100).toStringAsFixed(2),
  };
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