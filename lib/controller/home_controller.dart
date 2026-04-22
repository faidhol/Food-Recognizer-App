import 'dart:io';
import 'package:flutter/material.dart';
import 'package:submission/ui/result_page.dart';

class HomeController extends ChangeNotifier {
  File? _image;

  File? get image => _image;

  void setImage(File file) {
    _image = file;
    notifyListeners();
  }

  void goToResultPage(BuildContext context) {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan ambil gambar dulu")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResultPage(image: _image!)),
    );
  }
}
