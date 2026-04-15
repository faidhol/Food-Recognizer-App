import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:submission/controller/home_controller.dart';
import 'package:submission/ui/camera_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Food Recognizer App'),
      ),
      body: const SafeArea(
        child: Padding(padding: EdgeInsets.all(8.0), child: _HomeBody()),
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CameraPage()),
                );
              },
              child: Consumer<HomeController>(
                builder: (context, controller, child) {
                  if (controller.image != null) {
                    return Image.file(controller.image!);
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
