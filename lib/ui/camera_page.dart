import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:submission/controller/home_controller.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();

    _controller = CameraController(
      cameras![0], // kamera belakang
      ResolutionPreset.medium,
    );

    await _controller!.initialize();

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  Future<void> takePicture() async {
    if (!_controller!.value.isInitialized) return;

    final image = await _controller!.takePicture();

    final file = File(image.path);

    if (!mounted) return;

    context.read<HomeController>().setImage(file);

    Navigator.pop(context); // balik ke home
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Camera")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: CameraPreview(_controller!),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: takePicture,
                    child: const Text("Capture"),
                  ),
                ),
              ],
            ),
    );
  }
}