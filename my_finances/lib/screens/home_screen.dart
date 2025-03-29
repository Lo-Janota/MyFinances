import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'add_expense_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart'; // Crie essa tela se ainda não existir

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // Controla a aba selecionada
  double totalGasto = 1200.0;
  double limiteOrcamento = 2000.0;
  List<Map<String, dynamic>> despesas = [
    {'nome': 'Almoço', 'valor': 50.0, 'categoria': 'Alimentação', 'data': '25/03'},
    {'nome': 'Uber', 'valor': 20.0, 'categoria': 'Transporte', 'data': '24/03'},
    {'nome': 'Cinema', 'valor': 45.0, 'categoria': 'Lazer', 'data': '23/03'},
  ];

  // Alterar a tela exibida
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildHomeScreen(), // Tela principal
      ReportsScreen(), // Tela de Relatórios
      SettingsScreen(), // Tela de Configurações (perfil)
    ];

    return Scaffold(
      body: screens[_currentIndex], // Exibe a tela selecionada
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Color(0xFF2E8B57),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Relatórios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configurações',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Financeiro'),
        backgroundColor: Color(0xFF2E8B57),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildBudgetIndicator(),
            const SizedBox(height: 20),
            _buildChart(),
            const SizedBox(height: 20),
            Expanded(child: _buildTransactionHistory()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newExpense = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddExpenseScreen()),
          );

          if (newExpense != null) {
            setState(() {
              despesas.add(newExpense);
              totalGasto += newExpense['valor'];
            });
          }
        },
        tooltip: 'Adicionar Despesa',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildBudgetIndicator() {
    double percentage = totalGasto / limiteOrcamento;
    return Column(
      children: [
        Text(
          'Orçamento: R\$${limiteOrcamento.toStringAsFixed(2)}',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: Colors.grey[300],
          color: percentage > 0.8 ? Colors.red : Colors.green,
          minHeight: 8,
        ),
        Text('Gastos até agora: R\$${totalGasto.toStringAsFixed(2)}'),
      ],
    );
  }

  Widget _buildChart() {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: 40,
              title: 'Alimentação',
              color: Colors.blue,
            ),
            PieChartSectionData(
              value: 30,
              title: 'Transporte',
              color: Colors.red,
            ),
            PieChartSectionData(
              value: 30,
              title: 'Lazer',
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHistory() {
    return ListView.builder(
      itemCount: despesas.length,
      itemBuilder: (context, index) {
        var item = despesas[index];
        return Card(
          child: ListTile(
            title: Text(item['nome']),
            subtitle: Text('${item['categoria']} - ${item['data']}'),
            trailing: Text('R\$${item['valor'].toStringAsFixed(2)}'),
          ),
        );
      },
    );
  }
}
