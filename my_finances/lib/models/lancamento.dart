class Lancamento {
  String descricao;
  String data;
  double valor;
  String categoria;
  String tipo; // 'Receita' ou 'Despesa'

  Lancamento({
    required this.descricao,
    required this.data,
    required this.valor,
    required this.categoria,
    required this.tipo,
  });

  Map<String, dynamic> toJson() => {
    'descricao': descricao,
    'data': data,
    'valor': valor,
    'categoria': categoria,
    'tipo': tipo,
  };

  factory Lancamento.fromJson(Map<String, dynamic> json) => Lancamento(
    descricao: json['descricao'],
    data: json['data'],
    valor: json['valor'],
    categoria: json['categoria'],
    tipo: json['tipo'],
  );
}
