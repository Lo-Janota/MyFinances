import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>(); // Chave para o formulário
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
    if (_formKey.currentState!.validate()) { // Valida o formulário
      final String subject = "Sugestão do App de Finanças";
      final String body = "Nome: ${_nameController.text}\n\nMensagem:\n${_messageController.text}";
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: 'lorenzo.janota@icloud.com', // Mantido seu e-mail
        query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
      );

      try {
        if (await canLaunchUrl(emailUri)) {
          await launchUrl(emailUri);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Obrigado pela sua sugestão!"),
              backgroundColor: Color(0xFF2E8B57),
            ),
          );
          _nameController.clear();
          _messageController.clear();
        } else {
          throw 'Não foi possível abrir o app de e-mail.';
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro: ${e.toString()}"),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Definindo a cor primária para reutilização
    final Color primaryColor = const Color(0xFF2E8B57);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes e Informações'),
        backgroundColor: primaryColor,
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(Icons.info_outline), text: "Sobre o App"),
            Tab(icon: Icon(Icons.feedback_outlined), text: "Sugestões"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildAboutSection(context), _buildSuggestionsForm(context)],
      ),
    );
  }

  // --- ABA "SOBRE O APP" REFEITA ---
  Widget _buildAboutSection(BuildContext context) {
    final Color primaryColor = const Color(0xFF2E8B57);

    return ListView( // Usar ListView é melhor que SingleChildScrollView para listas de conteúdo
      padding: const EdgeInsets.all(16.0),
      children: [
        // Card do Header
        Card(
          elevation: 0,
          color: Colors.green.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Image.asset('assets/images/logo.png', height: 120),
                const SizedBox(height: 12),
                const Text(
                  "Seu Parceiro Financeiro",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2E8B57)),
                ),
                const SizedBox(height: 8),
                Text(
                  "Nossa missão é te dar clareza e poder para conquistar seus objetivos.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade700, height: 1.5),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Seção de Funcionalidades
        const Text("Principais Funcionalidades", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildFeatureTile(Icons.receipt_long_outlined, "Organize Tudo", "Registre despesas e receitas de forma rápida."),
        _buildFeatureTile(Icons.flag_outlined, "Sonhe Alto", "Defina sua meta de economia e acompanhe o progresso."),
        _buildFeatureTile(Icons.pie_chart_outline_rounded, "Entenda Seus Hábitos", "Analise seus gastos com gráficos intuitivos."),
        _buildFeatureTile(Icons.search_outlined, "Encontre o que Precisar", "Use a busca avançada para localizar qualquer lançamento."),
        const SizedBox(height: 24),

        // Seção de Informações
        const Text("Informações do App", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.info_outline, color: primaryColor),
                title: const Text("Versão do Aplicativo"),
                trailing: const Text("2.0.0", style: TextStyle(color: Colors.grey)),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: Icon(Icons.code_rounded, color: primaryColor),
                title: const Text("Desenvolvido por"),
                trailing: const Text("Lorenzo Janota", style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        )
      ],
    );
  }

  // Widget auxiliar para criar os itens da lista de funcionalidades
  Widget _buildFeatureTile(IconData icon, String title, String subtitle) {
    return Card(
      elevation: 0,
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF2E8B57), size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
      ),
    );
  }


  // --- ABA "SUGESTÕES" REFEITA ---
  Widget _buildSuggestionsForm(BuildContext context) {
    final Color primaryColor = const Color(0xFF2E8B57);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Form( // Usando um Form para validação
        key: _formKey,
        child: Column(
          children: [
            const Icon(Icons.lightbulb_outline_rounded, size: 50, color: Colors.amber),
            const SizedBox(height: 16),
            const Text(
              "Sua opinião constrói o futuro deste app!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Adoramos ouvir sugestões. Preencha os campos abaixo e nos ajude a melhorar.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Seu Nome",
                hintText: "Como podemos te chamar?",
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Por favor, digite seu nome' : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _messageController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "Sua Sugestão",
                hintText: "Conte-nos sua ideia...",
                alignLabelWithHint: true, // Alinha o label ao topo
                prefixIcon: Padding(
                   padding: EdgeInsets.fromLTRB(12, 0, 0, 70), // Ajusta o ícone
                   child: Icon(Icons.message_outlined),
                ),
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Por favor, escreva sua sugestão' : null,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _sendEmail,
              icon: const Icon(Icons.send_rounded),
              label: const Text("Enviar Sugestão", style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50), // Botão com altura fixa
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}