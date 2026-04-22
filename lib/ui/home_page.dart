import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:submission/controller/home_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Recognizer App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const SafeArea(
        child: Padding(padding: EdgeInsets.all(8.0), child: _HomeBody()),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);

    if (pickedFile == null) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.deepPurple,
          toolbarWidgetColor: Colors.white,
        ),
        IOSUiSettings(title: 'Crop Image'),
      ],
    );

    if (cropped == null) return;

    final file = File(cropped.path);

    if (!context.mounted) return;
    context.read<HomeController>().setImage(file);
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text("Kamera"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Galeri"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(context, ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: GestureDetector(
              onTap: () => _showPicker(context),
              child: Consumer<HomeController>(
                builder: (context, controller, child) {
                  if (controller.image != null) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(controller.image!),
                    );
                  }
                  return const Icon(Icons.camera_alt, size: 100);
                },
              ),
            ),
          ),
        ),
        FilledButton.tonal(
          onPressed: () {
            final controller = context.read<HomeController>();

            if (controller.image == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Ambil gambar dulu!")),
              );
              return;
            }

            controller.goToResultPage(context);
          },
          child: const Text("Analyze"),
        ),
      ],
    );
  }
}
