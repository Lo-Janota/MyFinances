import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<Map<String, dynamic>> despesas = [];
  String selectedMonth = DateFormat('MM/yyyy').format(DateTime.now());
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadDespesas();
  }

  Future<void> _loadDespesas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('despesas');
    if (data != null) {
      setState(() {
        despesas = List<Map<String, dynamic>>.from(
          jsonDecode(data).map((e) => Map<String, dynamic>.from(e)),
        );
      });
    }
  }

  List<Map<String, dynamic>> get filteredDespesas {
    return despesas.where((d) {
      final date = DateFormat('dd/MM/yyyy').parse(d['data']);
      final mesAno = DateFormat('MM/yyyy').format(date);
      return mesAno == selectedMonth && (selectedCategory == null || d['categoria'] == selectedCategory);
    }).toList();
  }

  List<String> get categorias {
    return despesas.map((d) => d['categoria'].toString()).toSet().toList();
  }

  double calcularTotalCategoria(String categoria) {
    return filteredDespesas.where((d) => d['categoria'] == categoria).fold(0.0, (soma, d) => soma + d['valor']);
  }

  Widget _buildChart() {
    final data = categorias
        .where((cat) => calcularTotalCategoria(cat) > 0)
        .map((cat) => PieChartSectionData(
              value: calcularTotalCategoria(cat),
              title: cat,
              radius: 60,
              color: Colors.primaries[categorias.indexOf(cat) % Colors.primaries.length],
            ))
        .toList();

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: data,
          sectionsSpace: 2,
          centerSpaceRadius: 30,
        ),
      ),
    );
  }

  Widget _buildDespesasPorCategoria() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categorias.map((cat) {
        final total = calcularTotalCategoria(cat);
        if (total == 0) return SizedBox.shrink();
        return ListTile(
          title: Text(cat),
          trailing: Text('R\$ ${total.toStringAsFixed(2)}'),
        );
      }).toList(),
    );
  }

  Widget _buildListaDespesas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: filteredDespesas.map((d) {
        return ListTile(
          title: Text(d['descricao']),
          subtitle: Text('${d['categoria']} - ${d['data']}'),
          trailing: Text('${d['tipo'] == 'receita' ? '+' : '-'}R\$ ${d['valor'].toStringAsFixed(2)}'),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Relatórios'),
        backgroundColor: Color(0xFF2E8B57),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedMonth,
                      items: _getLastMonths().map((m) => DropdownMenuItem(
                        value: m,
                        child: Text(m),
                      )).toList(),
                      onChanged: (val) {
                        setState(() => selectedMonth = val!);
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: DropdownButton<String?>(
                      isExpanded: true,
                      value: selectedCategory,
                      hint: Text('Categoria'),
                      items: [null, ...categorias].map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c ?? 'Todas'),
                      )).toList(),
                      onChanged: (val) {
                        setState(() => selectedCategory = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Gráfico por Categoria', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              _buildChart(),
              const SizedBox(height: 20),
              Text('Totais por Categoria', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              _buildDespesasPorCategoria(),
              const SizedBox(height: 20),
              Text('Gastos e Receitas do Mês', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              _buildListaDespesas(),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _getLastMonths() {
    final now = DateTime.now();
    return List.generate(12, (i) {
      final date = DateTime(now.year, now.month - i, 1);
      return DateFormat('MM/yyyy').format(date);
    });
  }
}