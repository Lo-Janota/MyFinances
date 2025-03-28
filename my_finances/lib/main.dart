import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart'; 
import 'screens/login_screen.dart'; 

void main() {
  runApp(
    DevicePreview(  // Habilita o Device Preview
      enabled: true, // Você pode desabilitar setando para false quando não for necessário
      builder: (context) => const MyApp(), // Constrói a aplicação
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginScreen(), // Definindo a tela de Login como a inicial
      builder: DevicePreview.appBuilder, // Habilita o Device Preview no MaterialApp
    );
  }
}
