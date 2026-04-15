import 'package:tflite_flutter/tflite_flutter.dart';

class MLService {
  static final MLService _instance = MLService._internal();

  factory MLService() => _instance;

  MLService._internal();

  Interpreter? _interpreter;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('mobilenet.tflite');
  }

  List<double> run(List input) {
    if (_interpreter == null) {
      throw Exception("Model belum di-load");
    }

    final output = List.generate(1, (_) => List.filled(2023, 0.0));

    _interpreter!.run(input, output);

    return List<double>.from(output[0]);
  }
}
