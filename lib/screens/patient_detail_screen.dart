import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../models/anamnese.dart';
import '../services/anamnese_service.dart';
import 'package:intl/intl.dart';

class PatientDetailScreen extends StatefulWidget {
  final Patient patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  final AnamneseService _anamneseService = AnamneseService();
  Anamnese? _anamnese;
  bool _isLoadingAnamnese = false;

  @override
  void initState() {
    super.initState();
    _loadAnamnese();
  }

  Future<void> _loadAnamnese() async {
    if (widget.patient.id == null) return;

    setState(() {
      _isLoadingAnamnese = true;
    });

    try {
      final anamnese = await _anamneseService.getAnamneseByPacienteId(
        widget.patient.id!,
      );
      setState(() {
        _anamnese = anamnese;
        _isLoadingAnamnese = false;
      });
    } catch (e) {
      print('Erro ao carregar anamnese: $e');
      setState(() {
        _isLoadingAnamnese = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.patient.nome ?? 'Paciente'),
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Color(0xFFE0E7FF),
            tabs: [
              Tab(icon: Icon(Icons.person), text: 'Informações'),
              Tab(icon: Icon(Icons.assignment), text: 'Anamnese'),
              Tab(
                icon: Icon(Icons.medical_services),
                text: 'Plano de Tratamento',
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              _buildInformacoesTab(),
              _buildAnamneseTab(),
              _buildPlanoTratamentoTab(),
            ],
          ),
        ),
      ),
    );
  }

  // Aba 1: Informações do Paciente
  Widget _buildInformacoesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar e Nome
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor:
                      widget.patient.cor != null &&
                          widget.patient.cor!.isNotEmpty
                      ? _parseColor(widget.patient.cor!)
                      : const Color(0xFF6366F1),
                  child: Text(
                    widget.patient.nome?.substring(0, 1).toUpperCase() ?? '?',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.patient.nome ?? 'Nome não informado',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                ),
                if (widget.patient.ativo != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: widget.patient.ativo!
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.patient.ativo! ? 'ATIVO' : 'INATIVO',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: widget.patient.ativo!
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Dados Pessoais
          _buildSectionTitle('Dados Pessoais'),
          const SizedBox(height: 16),
          _buildInfoCard([
            if (widget.patient.cpf != null && widget.patient.cpf!.isNotEmpty)
              _buildInfoRow(Icons.badge, 'CPF', widget.patient.cpf!),
            if (widget.patient.dataNascimento != null)
              _buildInfoRow(
                Icons.cake,
                'Data de Nascimento',
                DateFormat('dd/MM/yyyy').format(widget.patient.dataNascimento!),
              ),
            if (widget.patient.idade != null)
              _buildInfoRow(
                Icons.calendar_today,
                'Idade',
                '${widget.patient.idade} anos',
              ),
          ]),

          const SizedBox(height: 24),

          // Contato
          _buildSectionTitle('Contato'),
          const SizedBox(height: 16),
          _buildInfoCard([
            if (widget.patient.email != null &&
                widget.patient.email!.isNotEmpty)
              _buildInfoRow(Icons.email, 'E-mail', widget.patient.email!),
            if (widget.patient.celular != null &&
                widget.patient.celular!.isNotEmpty)
              _buildInfoRow(Icons.phone, 'Celular', widget.patient.celular!),
            if (widget.patient.whatsapp != null &&
                widget.patient.whatsapp!.isNotEmpty)
              _buildInfoRow(Icons.chat, 'WhatsApp', widget.patient.whatsapp!),
          ]),

          const SizedBox(height: 24),

          // Endereço
          _buildSectionTitle('Endereço'),
          const SizedBox(height: 16),
          _buildInfoCard([
            if (widget.patient.rua != null && widget.patient.rua!.isNotEmpty)
              _buildInfoRow(Icons.home, 'Rua', widget.patient.rua!),
            if (widget.patient.bairro != null &&
                widget.patient.bairro!.isNotEmpty)
              _buildInfoRow(
                Icons.location_city,
                'Bairro',
                widget.patient.bairro!,
              ),
            if (widget.patient.cidade != null &&
                widget.patient.cidade!.isNotEmpty)
              _buildInfoRow(
                Icons.location_on,
                'Cidade',
                '${widget.patient.cidade}${widget.patient.uf != null ? ' - ${widget.patient.uf}' : ''}',
              ),
            if (widget.patient.cep != null && widget.patient.cep!.isNotEmpty)
              _buildInfoRow(Icons.pin_drop, 'CEP', widget.patient.cep!),
          ]),

          const SizedBox(height: 24),

          // Convênio
          _buildSectionTitle('Convênio'),
          const SizedBox(height: 16),
          _buildInfoCard([
            if (widget.patient.convenio != null &&
                widget.patient.convenio!.isNotEmpty)
              _buildInfoRow(
                Icons.medical_services,
                'Plano',
                widget.patient.convenio!,
              )
            else
              _buildInfoRow(Icons.medical_services, 'Plano', 'Particular'),
            if (widget.patient.carteirinha != null &&
                widget.patient.carteirinha!.isNotEmpty)
              _buildInfoRow(
                Icons.credit_card,
                'Carteirinha',
                widget.patient.carteirinha!,
              ),
          ]),
        ],
      ),
    );
  }

  // Aba 2: Anamnese
  Widget _buildAnamneseTab() {
    if (_isLoadingAnamnese) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6366F1)),
      );
    }

    if (_anamnese == null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Anamnese não disponível',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Este paciente ainda não possui anamnese cadastrada',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Queixa Principal
          const Text(
            'Queixa principal',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              _anamnese!.queixaPrincipal ?? 'Não informado',
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
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
          if (_anamnese!.perguntas != null && _anamnese!.perguntas!.isNotEmpty)
            ..._anamnese!.perguntas!
                .map((pergunta) => _buildPerguntaItem(pergunta))
                .toList()
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                'Nenhuma pergunta cadastrada',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPerguntaItem(Pergunta pergunta) {
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
              TextSpan(text: pergunta.texto ?? ''),
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
            _buildRadioOption('Sim', pergunta.resposta == 'Sim'),
            const SizedBox(width: 24),
            _buildRadioOption('Não', pergunta.resposta == 'Não'),
            const SizedBox(width: 24),
            _buildRadioOption('Não sei', pergunta.resposta == 'Não sei'),
          ],
        ),
        const SizedBox(height: 12),

        // Campo de informações adicionais
        if (pergunta.infoAdicional != null &&
            pergunta.infoAdicional!.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              pergunta.infoAdicional!,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              'Informações adicionais (opcional)',
              style: TextStyle(fontSize: 13, color: Colors.grey[400]),
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildRadioOption(String label, bool isSelected) {
    return Row(
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
    );
  }

  // Aba 3: Plano de Tratamento
  Widget _buildPlanoTratamentoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Plano de Tratamento'),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.medical_services_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Plano de Tratamento não disponível',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'A funcionalidade de plano de tratamento será implementada em breve',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widgets auxiliares
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    if (children.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(
          'Nenhuma informação disponível',
          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF6366F1), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      String hexColor = colorString.replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return const Color(0xFF6366F1);
    }
  }
}
