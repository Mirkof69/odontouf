import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login/controller/login_controller.dart';
import 'panel_administrativo/dashboad/sections/Central/Usuarios/controller/usuario_controller.dart';
import 'panel_administrativo/dashboad/sections/Central/Usuarios/controller/usuario_controller_windows.dart';
import 'login/view/login_view_mobile.dart';
import 'login/view/login_view_windows.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Estrategia robusta anti-duplicado: intenta obtener la app por defecto;
  // si no existe (code == 'no-app'), recién entonces inicializa.
  try {
    Firebase.app();
  } on FirebaseException catch (e) {
    if (e.code == 'no-app') {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      rethrow;
    }
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final LoginController _loginController;
  late final dynamic usuarioController;

  @override
  void initState() {
    super.initState();
    _loginController = LoginController();
    // Selección automática del controlador de usuarios según plataforma
    if (kIsWeb) {
      usuarioController = UsuarioController();
    } else if (Platform.isWindows) {
      usuarioController = UsuarioControllerWindows();
    } else {
      usuarioController = UsuarioController();
    }
  }

  @override
  void dispose() {
    _loginController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clínica Unifranz Login',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) {
          if (kIsWeb) {
            return LoginViewWindows(controller: _loginController);
          }
          final width = MediaQuery.of(context).size.width;
          if (Platform.isWindows || width > 700) {
            return LoginViewWindows(controller: _loginController);
          }
          return LoginViewMobile(controller: _loginController);
        },
      ),
    );
  }
}
