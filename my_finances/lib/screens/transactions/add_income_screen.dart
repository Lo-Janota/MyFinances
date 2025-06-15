import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';



class AddIncomeScreen extends StatefulWidget {
  final Map<String, dynamic>? existingIncome;
  final String? docId;

  const AddIncomeScreen({super.key, this.existingIncome, this.docId});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descricaoController;
  late TextEditingController _valorController;
  late TextEditingController _origemController;
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
  _descricaoController =
      TextEditingController(text: widget.existingIncome?['descricao'] ?? '');
  _origemController =
      TextEditingController(text: widget.existingIncome?['origem'] ?? '');
  _dataController =
      TextEditingController(text: widget.existingIncome?['data'] ?? '');

  if (widget.existingIncome != null) {
      // Se sim, formata e exibe o valor existente
      final initialValue = widget.existingIncome?['valor'] ?? 0.0;
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
    _descricaoController.dispose();
    _valorController.dispose();
    _origemController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  Future<void> _saveIncome() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Lógica de erro se não houver usuário
      return;
    }

    setState(() => _isLoading = true);

    final String valorFormatado = _valorController.text;
    final String valorLimpo = valorFormatado.replaceAll('.', '').replaceAll(',', '.');
    final double valorNumerico = double.tryParse(valorLimpo) ?? 0.0;

    final incomeData = {
      'userId': user.uid,
      'descricao': _descricaoController.text,
      'valor': valorNumerico, // Salva o valor numérico limpo
      'origem': _origemController.text,
      'data': _dataController.text,
      'criadoEm': FieldValue.serverTimestamp(),
    };

    try {
      final firestore = FirebaseFirestore.instance;
      if (widget.docId != null) {
        await firestore.collection('receitas').doc(widget.docId).update(incomeData);
      } else {
        await firestore.collection('receitas').add(incomeData);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receita salva com sucesso!'), backgroundColor: Colors.green),
      );
      if (mounted) Navigator.pop(context, true);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar receita: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingIncome != null ? 'Editar Receita' : 'Nova Receita'),
        backgroundColor: const Color(0xFF3CB371),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição (Ex: Salário)'),
                validator: (v) => v!.isEmpty ? 'Informe uma descrição' : null,
              ),
              TextFormField(
                controller: _valorController,
                decoration: const InputDecoration(labelText: 'Valor (R\$)'),
                inputFormatters: [moneyFormatter],
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Informe um valor' : null,
              ),
              TextFormField(
                controller: _origemController,
                decoration: const InputDecoration(labelText: 'Origem (Ex: Empresa X, Freelance)'),
                validator: (v) => v!.isEmpty ? 'Informe a origem' : null,
              ),
              TextFormField(
                controller: _dataController,
                decoration: const InputDecoration(labelText: 'Data (dd/mm/yyyy)'),
                validator: (v) => v!.isEmpty ? 'Informe uma data' : null,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveIncome,
                      child: const Text('Salvar Receita'),
                    )
            ],
          ),
        ),
      ),
    );
  }
}