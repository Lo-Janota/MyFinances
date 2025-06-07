// home_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:my_finances/screens/add_expense_screen.dart';
import 'package:my_finances/screens/add_goal_screen.dart';
import 'package:my_finances/screens/add_income_screen.dart';
import 'package:my_finances/screens/login_screen.dart';
import 'package:my_finances/screens/reports_screen.dart';
import 'package:my_finances/screens/settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final User? user = FirebaseAuth.instance.currentUser;

  // ... (As funções _logout e _onTabTapped continuam iguais)
  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }


  // ✅ PASSO 1: LÓGICA PARA VERIFICAR SE A META EXISTE
  Future<void> _handleMetaButtonTap() async {
    if (user == null) return;

    // Busca no Firebase se já existe alguma meta para este usuário
    final metaQuery = await FirebaseFirestore.instance
        .collection('metas')
        .where('userId', isEqualTo: user!.uid)
        .limit(1) // Limita a 1, só precisamos saber se existe ou não
        .get();

    if (metaQuery.docs.isNotEmpty) {
      // Se a lista não estiver vazia, significa que JÁ EXISTE uma meta.
      // Mostra o pop-up de decisão.
      final existingGoalDoc = metaQuery.docs.first;
      if (mounted) _showExistingGoalDialog(existingGoalDoc);
    } else {
      // Se a lista estiver vazia, o usuário NÃO TEM meta.
      // Abre a tela de criação normalmente.
      if (mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => const AddGoalScreen()));
    }
  }

  // ✅ PASSO 2: FUNÇÃO QUE CRIA O POP-UP DE DECISÃO
  Future<void> _showExistingGoalDialog(DocumentSnapshot existingGoalDoc) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Meta já existente'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Você já possui uma meta. O que deseja fazer?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Excluir e Criar Nova'),
              onPressed: () async {
                // Deleta a meta antiga
                await existingGoalDoc.reference.delete();
                // Fecha o pop-up
                if (mounted) Navigator.of(context).pop();
                // Abre a tela para criar uma nova meta
                if (mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => const AddGoalScreen()));
              },
            ),
            ElevatedButton(
              child: const Text('Editar Meta'),
              onPressed: () {
                // Fecha o pop-up
                Navigator.of(context).pop();
                // Abre a tela de meta no modo de edição
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddGoalScreen(
                      existingGoal: existingGoalDoc.data() as Map<String, dynamic>,
                      docId: existingGoalDoc.id,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... (o início do seu build continua igual) ...
    // ... (AppBar, body, BottomNavigationBar...) ...
    final List<Widget> screens = [
      _buildHomeScreenContent(),
      const ReportsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E8B57),
        leading: IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: _logout,
        ),
        title: const Text(
          'Dashboard Financeiro',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: const Color(0xFF2E8B57),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Relatórios'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configurações'),
        ],
      ),
      floatingActionButton: _currentIndex == 0 ? _buildSpeedDial() : null,
    );
  }

  Widget _buildSpeedDial() {
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      backgroundColor: const Color(0xFF2E8B57),
      foregroundColor: Colors.white,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.money_off),
          label: 'Nova Despesa',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen())),
        ),
        SpeedDialChild(
          child: const Icon(Icons.attach_money),
          label: 'Nova Receita',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddIncomeScreen())),
        ),
        SpeedDialChild(
          child: const Icon(Icons.flag),
          label: 'Nova Meta',
          // ✅ PASSO 3: O BOTÃO AGORA CHAMA NOSSA NOVA LÓGICA
          onTap: _handleMetaButtonTap,
        ),
      ],
    );
  }

  // O resto dos seus widgets (_buildHomeScreenContent, _buildGoalProgressIndicator, etc.) continua exatamente igual a antes
  Widget _buildHomeScreenContent() {
    if (user == null) return const Center(child: Text("Usuário não logado."));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('receitas').where('userId', isEqualTo: user!.uid).snapshots(),
      builder: (context, receitasSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('despesas').where('userId', isEqualTo: user!.uid).snapshots(),
          builder: (context, despesasSnapshot) {
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('metas').where('userId', isEqualTo: user!.uid).snapshots(),
              builder: (context, metasSnapshot) {
                if (receitasSnapshot.hasError || despesasSnapshot.hasError || metasSnapshot.hasError) {
                  final error = receitasSnapshot.error ?? despesasSnapshot.error ?? metasSnapshot.error;
                  return Center(child: Text("Ocorreu um erro: $error"));
                }
                if (!receitasSnapshot.hasData || !despesasSnapshot.hasData || !metasSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final double totalReceitas = receitasSnapshot.data!.docs.fold(0.0, (sum, doc) => sum + (doc['valor'] ?? 0.0));
                final double totalDespesas = despesasSnapshot.data!.docs.fold(0.0, (sum, doc) => sum + (doc['valor'] ?? 0.0));
                
                final despesasDocs = despesasSnapshot.data!.docs;
                final metasDocs = metasSnapshot.data!.docs;

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildBudgetIndicator(totalDespesas, totalReceitas),
                      const SizedBox(height: 16),
                      _buildGoalProgressIndicator(metasDocs),
                      const SizedBox(height: 16),
                      _buildChart(despesasDocs),
                      const SizedBox(height: 16),
                      const Text("Histórico de Despesas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Expanded(child: _buildTransactionHistory(despesasDocs)),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildGoalProgressIndicator(List<QueryDocumentSnapshot> metas) {
    if (metas.isEmpty) {
      return const SizedBox.shrink();
    }
    final meta = metas.first.data() as Map<String, dynamic>;
    final titulo = meta['titulo'] ?? 'Minha Meta';
    final valorAtual = (meta['valorAtual'] ?? 0.0).toDouble();
    final valorAlvo = (meta['valorAlvo'] ?? 0.0).toDouble();
    double percentage = valorAlvo == 0 ? 1 : valorAtual / valorAlvo;
    if (percentage > 1) percentage = 1;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Meta: $titulo",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4682B4)),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: percentage,
              minHeight: 10,
              backgroundColor: Colors.grey[300],
              color: const Color(0xFF4682B4),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('R\$ ${valorAtual.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Alvo: R\$ ${valorAlvo.toStringAsFixed(2)}'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetIndicator(double totalGasto, double limiteOrcamento) {
    double percentage = limiteOrcamento == 0 ? 0 : totalGasto / limiteOrcamento;
    if (percentage > 1) percentage = 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Balanço Mensal (Receitas): R\$${limiteOrcamento.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: Colors.grey[300],
          color: percentage > 0.8 ? Colors.red : Colors.green,
          minHeight: 10,
        ),
        const SizedBox(height: 4),
        Text('Total de Despesas: R\$${totalGasto.toStringAsFixed(2)}'),
      ],
    );
  }

  Widget _buildChart(List<QueryDocumentSnapshot> despesas) {
    Map<String, double> categorias = {};
    for (var despesa in despesas) {
      final data = despesa.data() as Map<String, dynamic>;
      final categoria = data['categoria'] as String? ?? 'Outros';
      final valor = (data['valor'] as num?)?.toDouble() ?? 0.0;
      categorias[categoria] = (categorias[categoria] ?? 0) + valor;
    }

    if (categorias.isEmpty) {
      return const SizedBox(height: 200, child: Center(child: Text("Adicione despesas para ver o gráfico.")));
    }
    
    final double totalDespesas = categorias.values.fold(0.0, (a,b) => a+b);

    final List<Color> cores = [
      Colors.blue, Colors.orange, Colors.green, Colors.purple, Colors.red, Colors.teal,
    ];

    int index = 0;
    final sections = categorias.entries.map((entry) {
      final color = cores[index % cores.length];
      index++;
      return PieChartSectionData(
        value: entry.value,
        color: color,
        title: '${(entry.value / totalDespesas * 100).toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 40,
          sectionsSpace: 2,
        ),
      ),
    );
  }

  Widget _buildTransactionHistory(List<QueryDocumentSnapshot> despesas) {
    return ListView.builder(
      itemCount: despesas.length,
      itemBuilder: (context, index) {
        final doc = despesas[index];
        final item = doc.data() as Map<String, dynamic>;
        
        return Card(
          child: ListTile(
            title: Text(item['nome'] ?? 'Sem nome'),
            subtitle: Text('${item['categoria'] ?? 'Sem Categoria'} - ${item['data'] ?? 'Sem data'}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('R\$${(item['valor'] ?? 0.0).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20, color: Colors.blueGrey),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddExpenseScreen(existingExpense: item, docId: doc.id),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent),
                  onPressed: () async {
                    await FirebaseFirestore.instance.collection('despesas').doc(doc.id).delete();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}