import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/patient.dart';
import '../models/anamnese.dart';
import '../services/anamnese_service.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AnamneseFormScreen extends StatefulWidget {
  final Patient patient;
  final Anamnese? anamneseExistente;

  const AnamneseFormScreen({
    super.key,
    required this.patient,
    this.anamneseExistente,
  });

  @override
  State<AnamneseFormScreen> createState() => _AnamneseFormScreenState();
}

class _AnamneseFormScreenState extends State<AnamneseFormScreen> {
  final AnamneseService _anamneseService = AnamneseService();
  final TextEditingController _queixaPrincipalController =
      TextEditingController();
  final List<PerguntaForm> _perguntas = [];
  bool _isSaving = false;

  // Lista de perguntas padrão
  final List<String> _perguntasPadrao = [
    'Tem pressão alta?',
    'Possui alguma alergia? (Como penicilinas, AAS ou outra)',
    'Possui alguma alteração sanguínea?',
    'Já teve hemorragia diagnosticada?',
    'Está em tratamento médico?',
    'Toma algum medicamento regularmente?',
    'Já foi submetido a alguma cirurgia?',
    'Tem diabetes?',
    'Tem ou teve problemas cardíacos?',
    'Tem ou teve hepatite?',
    'Está grávida?',
    'Faz uso de bebidas alcoólicas?',
    'Fuma?',
  ];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.anamneseExistente != null) {
      // Carregar dados existentes
      _queixaPrincipalController.text =
          widget.anamneseExistente!.queixaPrincipal ?? '';

      if (widget.anamneseExistente!.perguntas != null) {
        for (var pergunta in widget.anamneseExistente!.perguntas!) {
          _perguntas.add(
            PerguntaForm(
              id: pergunta.id,
              texto: pergunta.texto ?? '',
              resposta: pergunta.resposta,
              infoAdicionalController: TextEditingController(
                text: pergunta.infoAdicional ?? '',
              ),
            ),
          );
        }
      }
    } else {
      // Criar formulário novo com perguntas padrão
      for (var texto in _perguntasPadrao) {
        _perguntas.add(
          PerguntaForm(
            texto: texto,
            infoAdicionalController: TextEditingController(),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _queixaPrincipalController.dispose();
    for (var pergunta in _perguntas) {
      pergunta.infoAdicionalController.dispose();
    }
    super.dispose();
  }

  Future<void> _salvarAnamnese() async {
    if (_queixaPrincipalController.text.trim().isEmpty) {
      Get.snackbar(
        'Atenção',
        'Por favor, preencha a queixa principal',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Verificar se todas as perguntas foram respondidas
    bool todasRespondidas = _perguntas.every((p) => p.resposta != null);
    if (!todasRespondidas) {
      Get.snackbar(
        'Atenção',
        'Por favor, responda todas as perguntas',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final anamnese = Anamnese(
        id: widget.anamneseExistente?.id,
        pacienteId: widget.patient.id,
        queixaPrincipal: _queixaPrincipalController.text.trim(),
        perguntas: _perguntas
            .map(
              (p) => Pergunta(
                id: p.id,
                texto: p.texto,
                resposta: p.resposta,
                infoAdicional: p.infoAdicionalController.text.trim(),
              ),
            )
            .toList(),
      );

      await _anamneseService.saveAnamnese(anamnese);

      Get.back(result: true); // Retorna true para indicar sucesso
      Get.snackbar(
        'Sucesso',
        'Anamnese salva com sucesso!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao salvar anamnese: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _gerarPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'FICHA DE ANAMNESE',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text('Clínica Odontológica'),
                    pw.Text('Endereço da Clínica'),
                    pw.Text('Telefone: (00) 0000-0000'),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Dados do Paciente
              pw.Text(
                'Paciente: ${widget.patient.nome ?? "Não informado"}',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Data: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 20),

              // Queixa Principal
              pw.Text(
                'Queixa Principal:',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                margin: const pw.EdgeInsets.only(top: 5, bottom: 15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  _queixaPrincipalController.text,
                  style: const pw.TextStyle(fontSize: 11),
                ),
              ),

              // Histórico Clínico
              pw.Text(
                'Histórico Clínico:',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),

              // Perguntas
              ..._perguntas.map((pergunta) {
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 10),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        pergunta.texto,
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                      pw.Text(
                        'Resposta: ${pergunta.resposta ?? "Não respondida"}',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      if (pergunta.infoAdicionalController.text.isNotEmpty)
                        pw.Text(
                          'Info: ${pergunta.infoAdicionalController.text}',
                          style: const pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.grey700,
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),

              pw.Spacer(),

              // Assinatura
              pw.Container(
                margin: const pw.EdgeInsets.only(top: 30),
                child: pw.Column(
                  children: [
                    pw.Container(
                      width: 300,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          top: pw.BorderSide(color: PdfColors.black),
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      widget.patient.nome ?? 'Paciente',
                      style: const pw.TextStyle(fontSize: 11),
                    ),
                    pw.Text(
                      'Assinatura do Paciente',
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anamnese'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _gerarPDF,
            tooltip: 'Imprimir/Gerar PDF',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Queixa Principal
                    const Text(
                      'Queixa principal *',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1E293B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _queixaPrincipalController,
                      decoration: InputDecoration(
                        hintText: 'Descreva a queixa principal do paciente',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF6366F1),
                            width: 2,
                          ),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),

                    // Histórico Clínico
                    const Text(
                      'Histórico Clínico',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Perguntas
                    ..._perguntas.asMap().entries.map((entry) {
                      final index = entry.key;
                      final pergunta = entry.value;
                      return _buildPerguntaFormItem(pergunta, index);
                    }).toList(),
                  ],
                ),
              ),
            ),

            // Botão Salvar
            Container(
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                24 + MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _salvarAnamnese,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Salvar Anamnese',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerguntaFormItem(PerguntaForm pergunta, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Texto da pergunta
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(text: pergunta.texto),
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Radio buttons
        Row(
          children: [
            _buildRadioOption('Sim', pergunta.resposta == 'Sim', () {
              setState(() {
                pergunta.resposta = 'Sim';
              });
            }),
            const SizedBox(width: 24),
            _buildRadioOption('Não', pergunta.resposta == 'Não', () {
              setState(() {
                pergunta.resposta = 'Não';
              });
            }),
            const SizedBox(width: 24),
            _buildRadioOption('Não sei', pergunta.resposta == 'Não sei', () {
              setState(() {
                pergunta.resposta = 'Não sei';
              });
            }),
          ],
        ),
        const SizedBox(height: 12),

        // Campo de informações adicionais
        TextField(
          controller: pergunta.infoAdicionalController,
          decoration: InputDecoration(
            hintText: 'Informações adicionais (opcional)',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
          style: const TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildRadioOption(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF6366F1)
                    : const Color(0xFFCBD5E1),
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isSelected
                  ? const Color(0xFF1E293B)
                  : const Color(0xFF64748B),
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class PerguntaForm {
  final int? id;
  final String texto;
  String? resposta;
  final TextEditingController infoAdicionalController;

  PerguntaForm({
    this.id,
    required this.texto,
    this.resposta,
    required this.infoAdicionalController,
  });
}
