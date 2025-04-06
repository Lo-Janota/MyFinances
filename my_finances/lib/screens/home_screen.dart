// home_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'add_expense_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  double totalGasto = 0.0;
  double limiteOrcamento = 2000.0;
  List<Map<String, dynamic>> despesas = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('despesas');
    if (data != null) {
      setState(() {
        despesas = List<Map<String, dynamic>>.from(json.decode(data));
        totalGasto = despesas.fold(0.0, (sum, item) => sum + item['valor']);
      });
    }
  }

  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('despesas', json.encode(despesas));
  }

  void _addDespesa(Map<String, dynamic> despesa) {
    setState(() {
      despesas.add(despesa);
      totalGasto += despesa['valor'];
    });
    _saveData();
  }

  void _editDespesa(int index, Map<String, dynamic> newDespesa) {
    setState(() {
      totalGasto -= despesas[index]['valor'];
      despesas[index] = newDespesa;
      totalGasto += newDespesa['valor'];
    });
    _saveData();
  }

  void _removeDespesa(int index) {
    setState(() {
      totalGasto -= despesas[index]['valor'];
      despesas.removeAt(index);
    });
    _saveData();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildHomeScreen(),
      ReportsScreen(),
      SettingsScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Color(0xFF2E8B57),
        unselectedItemColor: Colors.grey,
        items: const [
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
        title: const Text('Dashboard Financeiro'),
        backgroundColor: const Color(0xFF2E8B57),
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
            _addDespesa(newExpense);
          }
        },
        tooltip: 'Adicionar Despesa',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBudgetIndicator() {
    double percentage = limiteOrcamento == 0 ? 0 : totalGasto / limiteOrcamento;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Orçamento: R\$${limiteOrcamento.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    Map<String, double> categorias = {};
    for (var despesa in despesas) {
      categorias[despesa['categoria']] = (categorias[despesa['categoria']] ?? 0) + despesa['valor'];
    }

    final sections = categorias.entries.map((entry) {
      return PieChartSectionData(
        value: entry.value,
        title: entry.key,
        radius: 50,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(sections: sections),
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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('R\$${item['valor'].toStringAsFixed(2)}'),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () async {
                    final edited = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddExpenseScreen(existingExpense: item),
                      ),
                    );
                    if (edited != null) _editDespesa(index, edited);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () => _removeDespesa(index),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
