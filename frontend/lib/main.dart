import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/navigation.dart';

import 'firebase_options.dart';
import 'screens/Login/login_screen.dart';
import 'services/notification_service.dart'; // 👈 importa tu servicio

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicializamos Firebase (Auth + Messaging depende de esto)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Inicializamos notificaciones push
  //    - pide permisos
  //    - obtiene token FCM
  //    - si hay user logueado, lo registra en el backend
  await NotificationService.initAndRegisterToken();

  // 3. Lanzamos la app
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [routeObserver],
      home: const LoginScreen(),
    );
  }
}
