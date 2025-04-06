import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AddExpenseScreen extends StatefulWidget {
  final Map<String, dynamic>? existingExpense;
  final int? index;

  const AddExpenseScreen({super.key, this.existingExpense, this.index});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _valorController;
  late TextEditingController _categoriaController;
  late TextEditingController _dataController;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.existingExpense?['nome'] ?? '');
    _valorController = TextEditingController(text: widget.existingExpense?['valor']?.toString() ?? '');
    _categoriaController = TextEditingController(text: widget.existingExpense?['categoria'] ?? '');
    _dataController = TextEditingController(text: widget.existingExpense?['data'] ?? '');
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _valorController.dispose();
    _categoriaController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  Future<void> _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      final newExpense = {
        'nome': _nomeController.text,
        'valor': double.tryParse(_valorController.text) ?? 0.0,
        'categoria': _categoriaController.text,
        'data': _dataController.text,
      };
      Navigator.pop(context, newExpense);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingExpense != null ? 'Editar Despesa' : 'Nova Despesa'),
        backgroundColor: const Color(0xFF2E8B57),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator: (value) => value == null || value.isEmpty ? 'Informe uma descrição' : null,
              ),
              TextFormField(
                controller: _valorController,
                decoration: const InputDecoration(labelText: 'Valor (R\$)'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Informe um valor' : null,
              ),
              TextFormField(
                controller: _categoriaController,
                decoration: const InputDecoration(labelText: 'Categoria'),
                validator: (value) => value == null || value.isEmpty ? 'Informe uma categoria' : null,
              ),
              TextFormField(
                controller: _dataController,
                decoration: const InputDecoration(labelText: 'Data (dd/mm/yyyy)'),
                validator: (value) => value == null || value.isEmpty ? 'Informe uma data' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveExpense,
                child: const Text('Salvar'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
