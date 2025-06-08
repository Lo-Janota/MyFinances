import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum SortOptions { data, valor, nome }

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;

  String _searchQuery = "";
  SortOptions _sortOption = SortOptions.data;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  Query _buildFirestoreQuery() {
    Query query = FirebaseFirestore.instance
        .collection('despesas')
        .where('userId', isEqualTo: user!.uid);

    // SE O USUÁRIO ESTIVER PESQUISANDO POR TEXTO...
    if (_searchQuery.isNotEmpty) {
      String queryLowerCase = _searchQuery.toLowerCase();
      query = query
          .where('nome_lowercase', isGreaterThanOrEqualTo: queryLowerCase)
          .where('nome_lowercase', isLessThanOrEqualTo: '$queryLowerCase\uf8ff')
          .orderBy('nome_lowercase', descending: false);
    } 
    // SE A BARRA DE PESQUISA ESTIVER VAZIA...
    else {
      // Aplica a ordenação que o usuário escolheu
      switch (_sortOption) {
        case SortOptions.data:
          query = query.orderBy('data', descending: true);
          break;
        case SortOptions.valor:
          query = query.orderBy('valor', descending: true);
          break;
        case SortOptions.nome:
          query = query.orderBy('nome_lowercase', descending: false);
          break;
      }
    }
    return query;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          children: [
            _buildSearchPanel(),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _buildFirestoreQuery().snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Erro: ${snapshot.error}"));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "Nenhum resultado encontrado.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }
                  final docs = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      return _buildResultCard(data);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchPanel() {
  final bool isSearching = _searchQuery.isNotEmpty;

  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Alinha o texto à esquerda
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Pesquisar por nome da despesa...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 8.0, // Espaçamento horizontal entre os itens
            runSpacing: 4.0, // Espaçamento vertical se quebrar a linha
            crossAxisAlignment: WrapCrossAlignment.center, // Alinha verticalmente
            children: [
              const Text("Ordenar por:", style: TextStyle(fontWeight: FontWeight.bold)),
              
              // Botões de Ordenação
              ChoiceChip(
                label: const Text('Data'),
                selected: !isSearching && _sortOption == SortOptions.data,
                onSelected: isSearching ? null : (selected) {
                  setState(() => _sortOption = SortOptions.data);
                },
              ),
              ChoiceChip(
                label: const Text('Valor'),
                selected: !isSearching && _sortOption == SortOptions.valor,
                onSelected: isSearching ? null : (selected) {
                  setState(() => _sortOption = SortOptions.valor);
                },
              ),
              ChoiceChip(
                label: const Text('A-Z'),
                selected: isSearching || _sortOption == SortOptions.nome,
                onSelected: (selected) {
                  setState(() => _sortOption = SortOptions.nome);
                },
              ),
            ],
          )
        ],
      ),
    ),
  );
}

  Widget _buildResultCard(Map<String, dynamic> data) {
    final String dataFormatada = data['data'] ?? 'Sem data';
    final double valor = (data['valor'] as num?)?.toDouble() ?? 0.0;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(Icons.local_mall_outlined, color: Theme.of(context).primaryColor),
        ),
        title: Text(data['nome'] ?? 'Sem nome', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${data['categoria'] ?? 'Geral'}  •  $dataFormatada', style: const TextStyle(color: Colors.grey)),
        trailing: Text('R\$ ${valor.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 15)),
      ),
    );
  }
}