import 'package:tflite_flutter/tflite_flutter.dart';

class MLService {
  static final MLService _instance = MLService._internal();

  factory MLService() => _instance;

  MLService._internal();

  Interpreter? _interpreter;

  Future<void> loadModel() async {
    if (_interpreter != null) return;

    _interpreter = await Interpreter.fromAsset('mobilenet.tflite');
  }

  List<double> run(List input) {
    if (_interpreter == null) {
      throw Exception("Model belum di-load");
    }

    final outputShape = _interpreter!.getOutputTensor(0).shape;

    final output = List.generate(
      outputShape[0],
      (_) => List.filled(outputShape[1], 0.0),
    );

    _interpreter!.run(input, output);

    return List<double>.from(output[0]);
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
  }
}