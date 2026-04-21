import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';

class MLService {
  static final MLService _instance = MLService._internal();

  factory MLService() => _instance;

  MLService._internal();

  Interpreter? _interpreter;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/mobilenet.tflite');
  }

  List<double> run(Uint8List input) {
    if (_interpreter == null) {
      throw Exception("Model belum di-load");
    }

    final inputTensor = List.generate(
      1,
      (_) => List.generate(
        224,
        (y) => List.generate(224, (x) {
          final i = (y * 224 + x) * 3;
          return [input[i].toInt(), input[i + 1].toInt(), input[i + 2].toInt()];
        }),
      ),
    );

    final output = List.generate(1, (_) => List.filled(2024, 0));

    _interpreter!.run(inputTensor, output);

    return output[0].map((e) => e / 255.0).toList();
  }
}
