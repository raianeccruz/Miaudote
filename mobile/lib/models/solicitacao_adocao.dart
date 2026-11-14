class SolicitacaoAdocao {
  final int id;
  final String status;
  final SolicitacaoAnimal animal;
  final SolicitacaoUsuario usuario;
  final DateTime? createdAt;

  const SolicitacaoAdocao({
    required this.id,
    required this.status,
    required this.animal,
    required this.usuario,
    this.createdAt,
  });

  factory SolicitacaoAdocao.fromJson(Map<String, dynamic> json) {
    return SolicitacaoAdocao(
      id: json['id'],
      status: json['status'] ?? 'pendente',
      animal: SolicitacaoAnimal.fromJson(json['animal'] ?? {}),
      usuario: SolicitacaoUsuario.fromJson(json['usuario'] ?? {}),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}

class SolicitacaoAnimal {
  final int id;
  final String nome;
  final String especie;
  final String? imagem;

  const SolicitacaoAnimal({
    required this.id,
    required this.nome,
    required this.especie,
    this.imagem,
  });

  factory SolicitacaoAnimal.fromJson(Map<String, dynamic> json) {
    return SolicitacaoAnimal(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? 'Animal',
      especie: json['especie'] ?? '',
      imagem: json['imagem'],
    );
  }
}

class SolicitacaoUsuario {
  final int id;
  final String nome;

  const SolicitacaoUsuario({required this.id, required this.nome});

  factory SolicitacaoUsuario.fromJson(Map<String, dynamic> json) {
    return SolicitacaoUsuario(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? 'Usuário',
    );
  }
}
