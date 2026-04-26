import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:submission/controller/home_controller.dart';
import 'package:submission/ui/home_page.dart';
import 'package:submission/services/ml_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  try {
    await MLService().loadModel();
  } catch (e) {
    debugPrint("Error load model: $e");
  }

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => HomeController())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Recognizer App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
