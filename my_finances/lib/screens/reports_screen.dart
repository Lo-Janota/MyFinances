import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> despesas = [
    {'nome': 'Almoço', 'valor': 50.0, 'categoria': 'Alimentação', 'data': '25/03'},
    {'nome': 'Uber', 'valor': 20.0, 'categoria': 'Transporte', 'data': '24/03'},
    {'nome': 'Cinema', 'valor': 45.0, 'categoria': 'Lazer', 'data': '23/03'},
    {'nome': 'Supermercado', 'valor': 150.0, 'categoria': 'Alimentação', 'data': '22/03'},
    {'nome': 'Gasolina', 'valor': 100.0, 'categoria': 'Transporte', 'data': '21/03'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Relatórios Financeiros'),
        backgroundColor: Color(0xFF6A11CB), // Usando a mesma cor da tela inicial
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
