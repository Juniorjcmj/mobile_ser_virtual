class Pergunta {
  final int? id;
  final String? texto;
  final String? resposta;
  final String? infoAdicional;
  final String? anamnese;

  Pergunta({
    this.id,
    this.texto,
    this.resposta,
    this.infoAdicional,
    this.anamnese,
  });

  factory Pergunta.fromJson(Map<String, dynamic> json) {
    return Pergunta(
      id: json['id'] as int?,
      texto: json['texto'] as String?,
      resposta: json['resposta'] as String?,
      infoAdicional: json['infoAdicional'] as String?,
      anamnese: json['anamnese'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'texto': texto,
      'resposta': resposta,
      'infoAdicional': infoAdicional,
      'anamnese': anamnese,
    };
  }
}

class Anamnese {
  final int? id;
  final int? pacienteId;
  final String? queixaPrincipal;
  final List<Pergunta>? perguntas;

  Anamnese({this.id, this.pacienteId, this.queixaPrincipal, this.perguntas});

  factory Anamnese.fromJson(Map<String, dynamic> json) {
    return Anamnese(
      id: json['id'] as int?,
      pacienteId: json['pacienteId'] as int?,
      queixaPrincipal: json['queixaPrincipal'] as String?,
      perguntas: json['perguntas'] != null
          ? (json['perguntas'] as List)
                .map((p) => Pergunta.fromJson(p as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pacienteId': pacienteId,
      'queixaPrincipal': queixaPrincipal,
      'perguntas': perguntas?.map((p) => p.toJson()).toList(),
    };
  }
}
