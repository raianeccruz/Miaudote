class Usuario {
  final int id;
  final String nome;
  final String email;

  const Usuario({required this.id, required this.nome, required this.email});

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(id: json['id'], nome: json['name'], email: json['email']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': nome, 'email': email};
  }
}
