import 'package:intl/intl.dart';

class Consulta {
  final String? id;
  final DateTime? start;
  final DateTime? end;
  final String? valor;
  final String? tipo;
  final String? confirmado;
  final String? ausencia;
  final String? observacao;
  final String? numeroGuiaPlano;
  final String? pacienteId;
  final String? nomePaciente;
  final String? nomeDentista;
  final String? dentistaId;
  final DateTime? dataCriacao;
  final DateTime? dataAtualizacao;
  final String? status;
  final String? formaPagamento;
  final String? corPaciente;
  final String? corDentista;
  final String? participacao;

  Consulta({
    this.id,
    this.start,
    this.end,
    this.valor,
    this.tipo,
    this.confirmado,
    this.ausencia,
    this.observacao,
    this.numeroGuiaPlano,
    this.pacienteId,
    this.nomePaciente,
    this.nomeDentista,
    this.dentistaId,
    this.dataCriacao,
    this.dataAtualizacao,
    this.status,
    this.formaPagamento,
    this.corPaciente,
    this.corDentista,
    this.participacao,
  });

  factory Consulta.fromJson(Map<String, dynamic> json) {
    return Consulta(
      id: json['id'],
      start: json['start'] != null ? DateTime.tryParse(json['start']) : null,
      end: json['end'] != null ? DateTime.tryParse(json['end']) : null,
      valor: json['valor'],
      tipo: json['tipo'],
      confirmado: json['confirmado'],
      ausencia: json['ausencia'],
      observacao: json['observacao'],
      numeroGuiaPlano: json['numeroGuiaPlano'],
      pacienteId: json['pacienteId'],
      nomePaciente: json['nomePaciente'],
      nomeDentista: json['nomeDentista'],
      dentistaId: json['dentistaId'],
      dataCriacao: json['dataCriacao'] != null
          ? DateTime.tryParse(json['dataCriacao'])
          : null,
      dataAtualizacao: json['dataAtualizacao'] != null
          ? DateTime.tryParse(json['dataAtualizacao'])
          : null,
      status: json['status'],
      formaPagamento: json['formaPagamento'],
      corPaciente: json['corPaciente'],
      corDentista: json['corDentista'],
      participacao: json['participacao'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'start': start?.toIso8601String(),
    'end': end?.toIso8601String(),
    'valor': valor,
    'tipo': tipo,
    'confirmado': confirmado,
    'ausencia': ausencia,
    'observacao': observacao,
    'numeroGuiaPlano': numeroGuiaPlano,
    'pacienteId': pacienteId,
    'nomePaciente': nomePaciente,
    'nomeDentista': nomeDentista,
    'dentistaId': dentistaId,
    'dataCriacao': dataCriacao?.toIso8601String(),
    'dataAtualizacao': dataAtualizacao?.toIso8601String(),
    'status': status,
    'formaPagamento': formaPagamento,
    'corPaciente': corPaciente,
    'corDentista': corDentista,
    'participacao': participacao,
  };

  // Getters formatados
  String get horarioFormatado {
    if (start == null) return '';
    final format = DateFormat('HH:mm', 'pt_BR');
    final horarioInicio = format.format(start!);
    final horarioFim = end != null ? format.format(end!) : '';
    return horarioFim.isNotEmpty
        ? '$horarioInicio - $horarioFim'
        : horarioInicio;
  }

  String get dataFormatada {
    if (start == null) return '';
    final format = DateFormat('dd/MM/yyyy', 'pt_BR');
    return format.format(start!);
  }

  String get dataHoraFormatada {
    if (start == null) return '';
    final format = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');
    return format.format(start!);
  }

  String get statusFormatado {
    if (status == null) return 'Não definido';
    switch (status!.toUpperCase()) {
      case 'CONFIRMADA':
        return 'Confirmada';
      case 'PENDENTE':
        return 'Pendente';
      case 'CANCELADA':
        return 'Cancelada';
      case 'CONCLUIDA':
        return 'Concluída';
      default:
        return status!;
    }
  }

  bool get isConfirmada =>
      confirmado?.toLowerCase() == 'true' || confirmado == '1';
  bool get isAusente => ausencia?.toLowerCase() == 'true' || ausencia == '1';

  // Verificar se a consulta é no dia especificado
  bool isOnDay(DateTime day) {
    if (start == null) return false;
    final localStart = start!.toLocal();
    return localStart.year == day.year &&
        localStart.month == day.month &&
        localStart.day == day.day;
  }
}
