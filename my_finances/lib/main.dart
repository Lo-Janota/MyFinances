import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_finances/firebase_options.dart';
import 'package:my_finances/screens/home/home_screen.dart';
import 'package:my_finances/screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Finances',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      locale: const Locale('pt', 'BR'),
      home: const AuthCheck(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Escuta em tempo real as mudanças de autenticação do Firebase
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        
        // Se ainda está verificando, mostra uma tela de loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Se o snapshot tem dados (User não é nulo), o usuário está logado
        if (snapshot.hasData) {
          // Direciona para a HomeScreen
          return const HomeScreen();
        }

        // Se não tem dados (User é nulo), o usuário não está logado
        else {
          // Direciona para a LoginScreen
          return const LoginScreen();
        }
      },
    );
  }
}