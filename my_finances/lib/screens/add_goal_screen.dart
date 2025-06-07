import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.existingGoal?['titulo'] ?? '');
    _valorAlvoController = TextEditingController(text: widget.existingGoal?['valorAlvo']?.toString() ?? '');
    _valorAtualController = TextEditingController(text: widget.existingGoal?['valorAtual']?.toString() ?? '0.0'); // Começa com 0
    _prazoController = TextEditingController(text: widget.existingGoal?['prazo'] ?? '');
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

    final goalData = {
      'userId': user.uid,
      'titulo': _tituloController.text,
      'valorAlvo': double.tryParse(_valorAlvoController.text) ?? 0.0,
      'valorAtual': double.tryParse(_valorAtualController.text) ?? 0.0,
      'prazo': _prazoController.text,
    };

    try {
      final firestore = FirebaseFirestore.instance;
      // ✅ Salva na coleção 'metas'
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
        backgroundColor: const Color(0xFF4682B4), // Um azul para diferenciar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: 'Título da Meta (Ex: Viagem)'),
                validator: (v) => v!.isEmpty ? 'Defina um título' : null,
              ),
              TextFormField(
                controller: _valorAlvoController,
                decoration: const InputDecoration(labelText: 'Valor Alvo (R\$)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v!.isEmpty ? 'Defina o valor alvo' : null,
              ),
              TextFormField(
                controller: _valorAtualController,
                decoration: const InputDecoration(labelText: 'Valor Já Economizado (R\$)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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