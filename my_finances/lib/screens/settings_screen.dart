import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _sendEmail() async {
    final String subject = "Sugestão do App";
    final String body =
        "Nome: ${_nameController.text}\nSugestão:\n${_messageController.text}";
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'lorenzo.janota@icloud.com',
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Não foi possível abrir o e-mail")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Configurações'),
          backgroundColor: Color(0xFF2E8B57),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(icon: Icon(Icons.info), text: "Sobre o App"),
              Tab(icon: Icon(Icons.feedback), text: "Sugestões"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildAboutSection(),
            _buildSuggestionsForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Sobre o Aplicativo",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            "Este aplicativo foi desenvolvido para ajudar no controle financeiro pessoal. "
            "Com ele, você pode adicionar despesas, acompanhar gráficos e visualizar relatórios detalhados.",
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 20),
          Text(
            "Versão: 1.0.0",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            "Desenvolvido por Lorenzo Janota",
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: "Seu Nome",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 15),
          TextField(
            controller: _messageController,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: "Sua Sugestão",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _sendEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2E8B57),
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            child: Text(
              "Enviar Sugestão",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
