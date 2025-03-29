import 'package:flutter/material.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();
  String _categoriaSelecionada = 'Alimentação';

  void _salvarDespesa() {
    String nome = _nomeController.text.trim();
    double? valor = double.tryParse(_valorController.text.trim());

    if (nome.isEmpty || valor == null) {
      _mostrarNotificacao('Preencha todos os campos corretamente.');
      return;
    }

    Map<String, dynamic> novaDespesa = {
      'nome': nome,
      'valor': valor,
      'categoria': _categoriaSelecionada,
      'data': DateTime.now().toString().substring(0, 10),
    };

    Navigator.pop(context, novaDespesa);
  }

  void _mostrarNotificacao(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Adicionar Despesa')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(labelText: 'Nome da Despesa'),
            ),
            TextField(
              controller: _valorController,
              decoration: InputDecoration(labelText: 'Valor (R\$)'),
              keyboardType: TextInputType.number,
            ),
            DropdownButton<String>(
              value: _categoriaSelecionada,
              onChanged: (String? newValue) {
                setState(() {
                  _categoriaSelecionada = newValue!;
                });
              },
              items: ['Alimentação', 'Transporte', 'Lazer']
                  .map((categoria) => DropdownMenuItem(value: categoria, child: Text(categoria)))
                  .toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _salvarDespesa,
              child: Text('Salvar Despesa'),
            ),
          ],
        ),
      ),
    );
  }
}
