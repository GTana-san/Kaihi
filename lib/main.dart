import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'home/HomePage.dart';
import 'ProjectInputPageWithId.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth App',
        initialRoute: '/',
        onGenerateRoute: (settings) {
      // Web URL: https://xxx.web.app/#/input?project=abc123
      if (settings.name?.startsWith('/input') ?? false) {
        final uri = Uri.parse(settings.name!);
        final projectId = uri.queryParameters['project'];
        return MaterialPageRoute(
          builder: (_) => ProjectInputPageWithId(projectId: projectId),
        );
      }
      /*theme: ThemeData(
        primarySwatch: Colors.blue,
      ),*/
      return MaterialPageRoute(
        builder: (_) => const MyHomePage(), // デフォルトページ
      );
        },
      //home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
