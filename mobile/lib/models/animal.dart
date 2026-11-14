class Animal {
  final int id;
  final int userId;
  final String nome;
  final String especie;
  final int idade;
  final String descricao;
  final String cidade;
  final String estado;
  final String status;
  final String? imagem;

  const Animal({
    required this.id,
    required this.userId,
    required this.nome,
    required this.especie,
    required this.idade,
    required this.descricao,
    required this.cidade,
    required this.estado,
    required this.status,
    this.imagem,
  });

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: int.parse(json['id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      nome: json['nome']?.toString() ?? '',
      especie: json['especie']?.toString() ?? '',
      idade: int.tryParse(json['idade']?.toString() ?? '') ?? 0,
      descricao: json['descricao']?.toString() ?? '',
      cidade: json['cidade']?.toString() ?? '',
      estado: json['estado']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      imagem: json['imagem']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'nome': nome,
      'especie': especie,
      'idade': idade,
      'descricao': descricao,
      'cidade': cidade,
      'estado': estado,
      'status': status,
      'imagem': imagem,
    };
  }
}
