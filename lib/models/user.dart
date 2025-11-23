class User {
  final int? id;
  final String? nome;
  final String? email;
  final String? telefone;
  final String? cpf;
  final String? role;

  User({
    this.id,
    this.nome,
    this.email,
    this.telefone,
    this.cpf,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      telefone: json['telefone'],
      cpf: json['cpf'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'cpf': cpf,
      'role': role,
    };
  }
}
