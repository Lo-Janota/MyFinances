import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
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
      queryParameters: {'subject': subject, 'body': body},
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Sugestão enviada com sucesso!"),
          backgroundColor: Colors.green.shade600,
        ),
      );

      _nameController.clear();
      _messageController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Não foi possível abrir o e-mail"),
          backgroundColor: Colors.red.shade600,
        ),
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
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.info_outline), text: "Sobre o App"),
              Tab(icon: Icon(Icons.feedback_outlined), text: "Sugestões"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [_buildAboutSection(), _buildSuggestionsForm()],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Image.asset('assets/images/logo.png', height: 120),
                SizedBox(height: 20),
                Text(
                  "Sobre o Aplicativo",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E8B57),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Este aplicativo foi desenvolvido para ajudar no controle financeiro pessoal.\n"
            "Com ele, você pode:\n"
            "1) Adicionar Despesas\n"
            "2) Definir um Limite de Gastos\n"
            "3) Acompanhar os Gastos por um Gráfico\n"
            "4) Visualizar os Gastos de Vários Meses por um Relatório.\n\n"
            "Caso tenha alguma sugestão de mudança, nos mande a ideia por Email. "
            "Ficaremos felizes de modificar.\n"
            "Vale lembrar que essa é a primeira versão do APP.",
            style: TextStyle(fontSize: 16, height: 1.6),
          ),

          SizedBox(height: 25),
          Row(
            children: [
              Icon(Icons.info, size: 20, color: Color(0xFF2E8B57)),
              SizedBox(width: 5),
              Text("Versão: 1.0.0", style: TextStyle(fontSize: 16)),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.person, size: 20, color: Color(0xFF2E8B57)),
              SizedBox(width: 5),
              Text(
                "Desenvolvido por Lorenzo Janota",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            "Envie sua sugestão!",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E8B57),
            ),
          ),
          SizedBox(height: 25),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: "Seu Nome",
              prefixIcon: Icon(Icons.person),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          SizedBox(height: 20),
          TextField(
            controller: _messageController,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: "Sua Sugestão",
              prefixIcon: Icon(Icons.message),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _sendEmail,
              icon: Icon(Icons.send, color: Colors.white),
              label: Text(
                "Enviar Sugestão",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2E8B57),
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
