class Doctor {
  int? id;
  String? cro;
  String? nome;
  String? cpf;
  int? idade;
  String? email;
  String? celular;
  String? whatsapp;
  bool? ativo;
  String? rua;
  String? bairro;
  String? cidade;
  String? uf;
  String? cep;
  String? cor;
  double? participacao; // Changed to double as it looks like a number
  List<Especialidade>? especialidades;

  Doctor({
    this.id,
    this.cro,
    this.nome,
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
    this.participacao,
    this.especialidades,
  });

  Doctor.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    cro = json['cro'];
    nome = json['nome'];
    cpf = json['cpf'];
    idade = json['idade'];
    email = json['email'];
    celular = json['celular'];
    whatsapp = json['whatsapp'];
    ativo = json['ativo'];
    rua = json['rua'];
    bairro = json['bairro'];
    cidade = json['cidade'];
    uf = json['uf'];
    cep = json['cep'];
    cor = json['cor'];
    participacao = json['participacao'] != null
        ? (json['participacao'] is int
              ? (json['participacao'] as int).toDouble()
              : json['participacao'])
        : null;
    if (json['especialidades'] != null) {
      especialidades = <Especialidade>[];
      json['especialidades'].forEach((v) {
        especialidades!.add(Especialidade.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['cro'] = cro;
    data['nome'] = nome;
    data['cpf'] = cpf;
    data['idade'] = idade;
    data['email'] = email;
    data['celular'] = celular;
    data['whatsapp'] = whatsapp;
    data['ativo'] = ativo;
    data['rua'] = rua;
    data['bairro'] = bairro;
    data['cidade'] = cidade;
    data['uf'] = uf;
    data['cep'] = cep;
    data['cor'] = cor;
    data['participacao'] = participacao;
    if (especialidades != null) {
      data['especialidades'] = especialidades!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Especialidade {
  int? id;
  String? nome;
  String? descricao;
  Profissao? profissao;

  Especialidade({this.id, this.nome, this.descricao, this.profissao});

  Especialidade.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nome = json['nome'];
    descricao = json['descricao'];
    profissao = json['profissao'] != null
        ? Profissao.fromJson(json['profissao'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nome'] = nome;
    data['descricao'] = descricao;
    if (profissao != null) {
      data['profissao'] = profissao!.toJson();
    }
    return data;
  }
}

class Profissao {
  int? id;
  String? nome;
  String? codigo;
  String? descricao;

  Profissao({this.id, this.nome, this.codigo, this.descricao});

  Profissao.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nome = json['nome'];
    codigo = json['codigo'];
    descricao = json['descricao'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nome'] = nome;
    data['codigo'] = codigo;
    data['descricao'] = descricao;
    return data;
  }
}
