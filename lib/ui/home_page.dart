import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:submission/controller/home_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Food Recognizer App'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: const _HomeBody(),
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Center(
            child: GestureDetector(
              onTap: () async {
                final picker = ImagePicker();

                final pickedFile = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80,
                );

                if (pickedFile == null) return;

                final cropped = await ImageCropper().cropImage(
                  sourcePath: pickedFile.path,
                  uiSettings: [
                    AndroidUiSettings(
                      toolbarTitle: 'Crop Image',
                      toolbarColor: Colors.deepPurple,
                    ),
                  ],
                );

                if (cropped == null) return;

                final file = File(cropped.path);

                if (!context.mounted) return;
                context.read<HomeController>().setImage(file);
              },
              child: Consumer<HomeController>(
                builder: (context, controller, child) {
                  if (controller.image != null) {
                    return Image.file(controller.image!);
                  }
                  return const Icon(Icons.image, size: 100);
                },
              ),
            ),
          ),
        ),
        FilledButton.tonal(
          onPressed: () {
            context.read<HomeController>().goToResultPage(context);
          },
          child: const Text("Analyze"),
        ),
      ],
    );
  }
}
