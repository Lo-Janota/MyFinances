import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações'),
        backgroundColor: Color(0xFF6A11CB),
      ),
      body: Center(
        child: Text('Tela de Configurações'),
      ),
    );
  }
}
