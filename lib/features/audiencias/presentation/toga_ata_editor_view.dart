import 'package:flutter/material.dart';
import '../data/models/audiencia_painel_model.dart';
import '../services/toga_audiencias_service.dart';
import 'package:toga_mind_plus/core/toga_colors.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'toga_pos_audiencia_view.dart';
import 'package:toga_mind_plus/l10n/app_localizations.dart';
import 'widgets/toga_memoria_gabinete_widget.dart';

class TogaAtaEditorView extends StatefulWidget {
  final AudienciaPainel audiencia;

  const TogaAtaEditorView({Key? key, required this.audiencia}) : super(key: key);

  @override
  State<TogaAtaEditorView> createState() => _TogaAtaEditorViewState();
}

class _TogaAtaEditorViewState extends State<TogaAtaEditorView> {
  final TextEditingController _ataController = TextEditingController();
  bool _isGeneratingDocx = false;
  String? _statusMessage;
  String _horarioInicio = "";

  @override
  void initState() {
    super.initState();
    _horarioInicio = DateFormat('HH:mm:ss').format(DateTime.now());
    
    // Texto Inicial Padrão de Tribunal
    _ataController.text = "Aos ${DateFormat('dd/MM/yyyy').format(DateTime.now())}, às $_horarioInicio, nesta cidade e comarca, "
        "presente o(a) Exmo(a). Sr(a). Juiz(a) de Direito. Verificou-se a presença das seguintes partes: "
        "${_formatarPartes(widget.audiencia.partes)}.\n\n"
        "Aberta a audiência, a conciliação resultou INFRUTÍFERA. "
        "Passou-se à instrução onde as seguintes ocorrências foram registradas:\n\n[INSERIR RELATO AQUI]";
  }

  String _formatarPartes(Map<String, dynamic>? partes) {
    if (partes == null || partes.isEmpty) return "partes não especificadas nos autos processuais";
    final List<String> p = [];
    if (partes.containsKey('polo_ativo')) p.add("Polo Ativo: ${partes['polo_ativo']}");
    if (partes.containsKey('polo_passivo')) p.add("Polo Passivo: ${partes['polo_passivo']}");
    return p.join(" / ");
  }

  Future<void> _exportarParaDocx() async {
    if (!mounted) return;
    setState(() {
      _isGeneratingDocx = true;
      _statusMessage = null;
    });

    final horarioFim = DateFormat('HH:mm:ss').format(DateTime.now());

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/gerar-ata-docx'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'processo_id': widget.audiencia.idProcesso,
          'partes': _formatarPartes(widget.audiencia.partes),
          'texto_ata': _ataController.text,
          'horario_inicio': _horarioInicio,
          'horario_fim': horarioFim,
        }),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        
        if (mounted) {
           Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TogaPosAudienciaView(destinoArquivo: decoded['caminho_salvo']),
              ),
           );
        }
      } else {
        setState(() => _statusMessage = "Erro ao exportar: HTTP ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _statusMessage = "Falha de Conexão Local: $e");
    } finally {
      if (mounted) {
        setState(() => _isGeneratingDocx = false);
      }
    }
  }

  @override
  void dispose() {
    _ataController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('${l10n.chat_title}: Celebração de Ata', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF10AC84), // Verde Gabinete Oficial
        foregroundColor: Colors.white,
      ),
      body: Row(
        children: [
          // Painel Esquerdo: Briefing de Gabinete RAG
          _buildLeftPanel(),
          
          const VerticalDivider(width: 1, thickness: 1, color: Colors.grey),
          
          // Painel Direito: Redação Ocorrências DOCX
          _buildRightPanel(l10n),
        ],
      ),
    );
  }

  Widget _buildLeftPanel() {
    return Expanded(
      flex: 1,
      child: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF10AC84).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.gavel, color: Color(0xFF0C8A69)),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Processo CNJ: ${widget.audiencia.idProcesso}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0C8A69), fontSize: 16))),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text("Briefing Escaneado (IA Local)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
              const Divider(),
              if (widget.audiencia.resumoPrevia != null) ...[
                const SizedBox(height: 8),
                Text(widget.audiencia.resumoPrevia!, style: const TextStyle(fontSize: 14)),
              ],
              const SizedBox(height: 16),
              if (widget.audiencia.historicoUtilizado == true)
                 TogaMemoriaGabineteWidget(usandoHistorico: true),
              const SizedBox(height: 16),
              const Text("Pontos Controvertidos e Perguntas", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
              const Divider(),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFD54F)),
                ),
                child: Text(
                  widget.audiencia.pontoControvertido ?? "Nenhuma análise RAG pré-carregada para este processo.",
                  style: const TextStyle(color: Colors.black87, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRightPanel(AppLocalizations l10n) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.edit_document, color: Colors.black54),
                SizedBox(width: 8),
                Text("Redação Oficial da Ata (.docx)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: TextField(
                  controller: _ataController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(fontSize: 15, height: 1.6),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(24),
                    hintText: "Digite os termos do acordo ou depoimentos de instrução...",
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_statusMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: _statusMessage!.contains("sucesso") ? const Color(0xFFF0FDF4) : Colors.red.shade50,
                  border: Border.all(color: _statusMessage!.contains("sucesso") ? const Color(0xFF10AC84) : Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusMessage!,
                  style: TextStyle(
                    color: _statusMessage!.contains("sucesso") ? const Color(0xFF0C8A69) : Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                icon: _isGeneratingDocx 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.file_download),
                label: Text(_isGeneratingDocx ? l10n.msg_analyzing : l10n.btnSalvarAta, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TogaColors.azulPetroleo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _isGeneratingDocx ? null : _exportarParaDocx,
              ),
            )
          ],
        ),
      ),
    );
  }
}
