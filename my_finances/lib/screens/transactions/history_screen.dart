import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // O DefaultTabController gerencia todo o estado das abas para nós.
    return DefaultTabController(
      length: 2, // Teremos 2 abas: Despesas e Receitas
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Meus Lançamentos'),
          backgroundColor: const Color(0xFF2E8B57),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Despesas', icon: Icon(Icons.arrow_downward)),
              Tab(text: 'Receitas', icon: Icon(Icons.arrow_upward)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // Conteúdo da primeira aba
            TransactionList(collectionName: 'despesas'),
            // Conteúdo da segunda aba
            TransactionList(collectionName: 'receitas'),
          ],
        ),
      ),
    );
  }
}

class TransactionList extends StatelessWidget {
  final String collectionName;
  const TransactionList({super.key, required this.collectionName});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Faça login para ver seus dados.'));
    }
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(collectionName)
          .where('userId', isEqualTo: user.uid)
          .snapshots(),
      
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      
        if (snapshot.hasError) {
          return Center(child: Text('Ocorreu um erro: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Nenhum lançamento em "$collectionName".'));
        }

        return ListView(
    
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
            String title = data['nome'] ?? data['descricao'] ?? 'Sem Título';

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ListTile(
                    title: Text(title),
                    subtitle: Text(
                      data['categoria'] ?? data['origem'] ?? 'Geral',
                    ),
                    trailing: Text(
                      // ✅ AQUI ESTÁ A MUDANÇA
                      NumberFormat.currency(
                        locale: 'pt_BR',
                        symbol: 'R\$',
                      ).format(data['valor'] ?? 0.0),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            collectionName == 'despesas'
                                ? Colors.red
                                : Colors.green,
                      ),
                    ),
                  ),
                );
              }).toList(),
        );
      },
    );
  }
}
