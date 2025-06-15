import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

class AddExpenseScreen extends StatefulWidget {
  final Map<String, dynamic>? existingExpense;
  final String? docId; 

  const AddExpenseScreen({super.key, this.existingExpense, this.docId});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _valorController;
  late TextEditingController _categoriaController;
  late TextEditingController _dataController;
  bool _isLoading = false;

  final moneyFormatter = MoneyInputFormatter(
  thousandSeparator: ThousandSeparator.Period, // ponto para milhar
  mantissaLength: 2,
  leadingSymbol: '',
  useSymbolPadding: false,
);

  @override
  void initState() {
    super.initState();

    _nomeController = TextEditingController(
      text: widget.existingExpense?['nome'] ?? '',
    );

    _categoriaController = TextEditingController(
      text: widget.existingExpense?['categoria'] ?? '',
    );

    _dataController = TextEditingController(
      text: widget.existingExpense?['data'] ?? '',
    );

    if (widget.existingExpense != null) {
      // Se sim, formata e exibe o valor existente
      final initialValue = widget.existingExpense?['valor'] ?? 0.0;
      final String valorComVirgula = initialValue
          .toStringAsFixed(2)
          .replaceAll('.', ',');
      _valorController = TextEditingController(
        text: toCurrencyString(
          initialValue.toString(),
          thousandSeparator: ThousandSeparator.Period,
          mantissaLength: 2,
          leadingSymbol: '',
        ),
      );
    } else {
      // Se for uma nova receita, o campo começa vazio
      _valorController = TextEditingController();
    }
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro: Nenhum usuário logado.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final String valorFormatado = _valorController.text;
    // Remove os pontos de milhar e troca a vírgula por ponto para salvar no Firebase
    final String valorLimpo = valorFormatado.replaceAll('.', '').replaceAll(',', '.');
    final double valorNumerico = double.tryParse(valorLimpo) ?? 0.0;

    final nomeOriginal = _nomeController.text;
    final expenseData = {
      'userId': user.uid,
      'nome': nomeOriginal,
      'nome_lowercase': nomeOriginal.toLowerCase(),
      'valor': valorNumerico,
      'categoria': _categoriaController.text,
      'data': _dataController.text,
      'criadoEm': FieldValue.serverTimestamp(),
    };
    try {
      final firestore = FirebaseFirestore.instance;
      
      if (widget.docId != null) {
        // Lógica de Edição
        await firestore.collection('despesas').doc(widget.docId).update(expenseData);
      } else {
        await firestore.collection('despesas').add(expenseData);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Despesa salva com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      // Fecha a tela após o sucesso
      if (mounted) Navigator.pop(context, true);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ocorreu um erro ao salvar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
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
                inputFormatters: [moneyFormatter], // Aplica a máscara
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Valor (R\$)'),
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
              // Mostra um loading ou o botão de salvar
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
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