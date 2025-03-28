import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'add_expense_screen.dart'; // Tela para adicionar despesas
import 'reports_screen.dart'; // Tela de relatórios, crie esse arquivo se ainda não existir

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double totalGasto = 1200.0;
  double limiteOrcamento = 2000.0;
  List<Map<String, dynamic>> despesas = [
    {'nome': 'Almoço', 'valor': 50.0, 'categoria': 'Alimentação', 'data': '25/03'},
    {'nome': 'Uber', 'valor': 20.0, 'categoria': 'Transporte', 'data': '24/03'},
    {'nome': 'Cinema', 'valor': 45.0, 'categoria': 'Lazer', 'data': '23/03'},
  ];

  void _setBudgetLimit() async {
    final newLimit = await showDialog<double>(
      context: context,
      builder: (context) {
        double tempLimit = limiteOrcamento;
        return AlertDialog(
          title: Text('Defina um novo limite de orçamento'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Novo limite'),
            onChanged: (value) {
              tempLimit = double.tryParse(value) ?? tempLimit;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, tempLimit);
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (newLimit != null) {
      setState(() {
        limiteOrcamento = newLimit;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Financeiro'),
        backgroundColor: Color(0xFF6A11CB), // Mesma cor da tela de login
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _setBudgetLimit, // Botão para definir limite de orçamento
            backgroundColor: Colors.orange,
            child: Icon(Icons.attach_money),
            tooltip: 'Definir Limite',
          ),
          SizedBox(height: 16),
          FloatingActionButton(
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
            child: Icon(Icons.add),
            tooltip: 'Adicionar Despesa',
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReportsScreen()), // Navega para os relatórios
              );
            },
            child: Icon(Icons.bar_chart),
            tooltip: 'Relatórios',
          ),
        ],
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
