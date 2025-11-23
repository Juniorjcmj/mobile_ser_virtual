class Patient {
  final int? id;
  final String? nome;
  final String? convenio;
  final String? carteirinha;
  final String? cpf;
  final int? idade;
  final String? email;
  final String? celular;
  final String? whatsapp;
  final bool? ativo;
  final String? rua;
  final String? bairro;
  final String? cidade;
  final String? uf;
  final String? cep;
  final String? cor;
  final DateTime? dataNascimento;
  final DateTime? dataCriacao;
  final DateTime? dataAtualizacao;

  Patient({
    this.id,
    this.nome,
    this.convenio,
    this.carteirinha,
    this.cpf,
    this.idade,
    this.email,
    this.celular,
    this.whatsapp,
    this.ativo,
    this.rua,
    this.bairro,
    this.cidade,
    this.uf,
    this.cep,
    this.cor,
    this.dataNascimento,
    this.dataCriacao,
    this.dataAtualizacao,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as int?,
      nome: json['nome'] as String?,
      convenio: json['convenio'] as String?,
      carteirinha: json['carteirinha'] as String?,
      cpf: json['cpf'] as String?,
      idade: json['idade'] as int?,
      email: json['email'] as String?,
      celular: json['celular'] as String?,
      whatsapp: json['whatsapp'] as String?,
      ativo: json['ativo'] as bool?,
      rua: json['rua'] as String?,
      bairro: json['bairro'] as String?,
      cidade: json['cidade'] as String?,
      uf: json['uf'] as String?,
      cep: json['cep'] as String?,
      cor: json['cor'] as String?,
      dataNascimento: json['dataNascimento'] != null
          ? DateTime.parse(json['dataNascimento'] as String)
          : null,
      dataCriacao: json['dataCriacao'] != null
          ? DateTime.parse(json['dataCriacao'] as String)
          : null,
      dataAtualizacao: json['dataAtualizacao'] != null
          ? DateTime.parse(json['dataAtualizacao'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'convenio': convenio,
      'carteirinha': carteirinha,
      'cpf': cpf,
      'idade': idade,
      'email': email,
      'celular': celular,
      'whatsapp': whatsapp,
      'ativo': ativo,
      'rua': rua,
      'bairro': bairro,
      'cidade': cidade,
      'uf': uf,
      'cep': cep,
      'cor': cor,
      'dataNascimento': dataNascimento?.toIso8601String(),
      'dataCriacao': dataCriacao?.toIso8601String(),
      'dataAtualizacao': dataAtualizacao?.toIso8601String(),
    };
  }
}
