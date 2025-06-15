import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

class AddGoalScreen extends StatefulWidget {
  final Map<String, dynamic>? existingGoal;
  final String? docId;

  const AddGoalScreen({super.key, this.existingGoal, this.docId});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tituloController;
  late TextEditingController _valorAlvoController;
  late TextEditingController _valorAtualController;
  late TextEditingController _prazoController;

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

  _tituloController =
      TextEditingController(text: widget.existingGoal?['titulo'] ?? '');
  _prazoController =
      TextEditingController(text: widget.existingGoal?['prazo'] ?? '');

  if (widget.existingGoal != null) {
    final initialValueAlvo = widget.existingGoal?['valorAlvo'] ?? 0.0;
    _valorAlvoController = TextEditingController(
      text: toCurrencyString(
        initialValueAlvo.toString(),
        thousandSeparator: ThousandSeparator.Period,
        mantissaLength: 2,
        leadingSymbol: '',
      ),
    );

    final initialValueAtual = widget.existingGoal?['valorAtual'] ?? 0.0;
    _valorAtualController = TextEditingController(
      text: toCurrencyString(
        initialValueAtual.toString(),
        thousandSeparator: ThousandSeparator.Period,
        mantissaLength: 2,
        leadingSymbol: '',
      ),
    );
  } else {
    _valorAlvoController = TextEditingController();
    _valorAtualController = TextEditingController();
  }
}
    

  @override
  void dispose() {
    _tituloController.dispose();
    _valorAlvoController.dispose();
    _valorAtualController.dispose();
    _prazoController.dispose();
    super.dispose();
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Lógica de erro se não houver usuário
      return;
    }

    setState(() => _isLoading = true);

    final String valorAlvoFormatado = _valorAlvoController.text;
    final String valorAlvoLimpo = valorAlvoFormatado.replaceAll('.', '').replaceAll(',', '.');
    final double valorAlvoNumerico = double.tryParse(valorAlvoLimpo) ?? 0.0;
    
    final String valorAtualFormatado = _valorAtualController.text;
    final String valorAtualLimpo = valorAtualFormatado.replaceAll('.', '').replaceAll(',', '.');
    final double valorAtualNumerico = double.tryParse(valorAtualLimpo) ?? 0.0;

    final goalData = {
      'userId': user.uid,
      'titulo': _tituloController.text,
      'valorAlvo': valorAlvoNumerico, // Salva o valor numérico
      'valorAtual': valorAtualNumerico, // Salva o valor numérico
      'prazo': _prazoController.text,
    };

    try {
      final firestore = FirebaseFirestore.instance;
      if (widget.docId != null) {
        await firestore.collection('metas').doc(widget.docId).update(goalData);
      } else {
        await firestore.collection('metas').add(goalData);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meta salva com sucesso!'), backgroundColor: Colors.green),
      );
      if (mounted) Navigator.pop(context, true);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar meta: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingGoal != null ? 'Editar Meta' : 'Nova Meta/Orçamento'),
        backgroundColor: const Color(0xFF4682B4), 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                    labelText: 'Título da Meta (Ex: Viagem)'),
                validator: (v) => v!.isEmpty ? 'Defina um título' : null,
              ),
              // ✅ 3. CAMPO DE VALOR ALVO COM A MÁSCARA
              TextFormField(
                controller: _valorAlvoController,
                decoration: const InputDecoration(labelText: 'Valor Alvo (R\$)'),
                inputFormatters: [moneyFormatter],
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Defina o valor alvo' : null,
              ),
              // ✅ 3. CAMPO DE VALOR ATUAL COM A MÁSCARA
              TextFormField(
                controller: _valorAtualController,
                decoration:
                    const InputDecoration(labelText: 'Valor Já Economizado (R\$)'),
                inputFormatters: [moneyFormatter],
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Defina o valor atual' : null,
              ),
              TextFormField(
                controller: _prazoController,
                decoration: const InputDecoration(labelText: 'Prazo (dd/mm/yyyy)'),
                validator: (v) => v!.isEmpty ? 'Defina um prazo' : null,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveGoal,
                      child: const Text('Salvar Meta'),
                    )
            ],
          ),
        ),
      ),
    );
  }
}