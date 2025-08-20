import 'package:flutter/material.dart';
import 'package:app_pulse/screens/welcome_screen.dart';
import 'package:app_pulse/theme/theme.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app_pulse/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:app_pulse/mqtt/mqtt_service.dart';

Future<void> main() async {
  await Hive.initFlutter();
  await Hive.openBox('userData');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(ChangeNotifierProvider(
      create: (_) => MqttService(),
      child: const MyApp(),
    ),);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: lightMode,
      home: WelcomeScreen(),
    );
  }
}
