import 'package:flutter/material.dart';
import 'package:toga_mind_plus/core/toga_colors.dart';
import '../data/models/audiencia_painel_model.dart';
import '../services/toga_audiencias_service.dart';
import 'widgets/toga_audiencia_card.dart';
import 'package:toga_mind_plus/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

class TogaAudienciasView extends StatefulWidget {
  const TogaAudienciasView({Key? key}) : super(key: key);

  @override
  State<TogaAudienciasView> createState() => _TogaAudienciasViewState();
}

class _TogaAudienciasViewState extends State<TogaAudienciasView> {
  final TogaAudienciasService _service = TogaAudienciasService();
  List<AudienciaPainel> _audiencias = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _carregarAudiencias();
  }

  Future<void> _carregarAudiencias() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _service.listarAudiencias();
      if (!mounted) return;
      setState(() {
        _audiencias = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(l10n.pautaTitulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF10AC84), // Verde-Gabinete Protocolaro)
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar Pauta',
            onPressed: _carregarAudiencias,
          )
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarDialogNovaAudiencia,
        backgroundColor: const Color(0xFFFC2D7C), // Magenta Padrão TogaMind
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nova Audiência', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _mostrarDialogNovaAudiencia() {
    final processoController = TextEditingController();
    final dataController = TextEditingController(text: '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}');
    final horarioController = TextEditingController();
    final lembreteController = TextEditingController();
    String tipoSelecionado = 'Instrução e Julgamento';
    String? caminhoAnexoSelecionado;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Adicionar à Pauta', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: processoController,
                      decoration: const InputDecoration(
                        labelText: 'Número do Processo (CNJ)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.gavel),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: dataController,
                      decoration: const InputDecoration(
                        labelText: 'Data da Audiência (ex: 15/05/2026)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: horarioController,
                      decoration: const InputDecoration(
                        labelText: 'Horário (ex: 14:30)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.access_time),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: lembreteController,
                      maxLength: 150,
                      decoration: const InputDecoration(
                        labelText: 'Lembretes e Observações Extras (Opcional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note_alt_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: tipoSelecionado,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Audiência',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: ['Instrução e Julgamento', 'Conciliação', 'Custódia', 'Telepresencial']
                          .map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)))
                          .toList(),
                      onChanged: (val) {
                        setDialogState(() {
                          tipoSelecionado = val!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () async {
                        FilePickerResult? result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf'],
                        );
                        if (result != null) {
                          setDialogState(() {
                            caminhoAnexoSelecionado = result.files.single.path;
                          });
                        }
                      },
                      icon: Icon(
                        caminhoAnexoSelecionado != null ? Icons.check_circle : Icons.upload_file,
                        color: caminhoAnexoSelecionado != null ? Colors.green : const Color(0xFFFC2D7C),
                      ),
                      label: Text(
                        caminhoAnexoSelecionado != null 
                            ? 'PDF Anexado: ${p.basename(caminhoAnexoSelecionado!)}' 
                            : 'Anexar Inicial/Documento (PDF)',
                        style: TextStyle(
                            color: caminhoAnexoSelecionado != null ? Colors.green : const Color(0xFFFC2D7C),
                            overflow: TextOverflow.ellipsis),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: caminhoAnexoSelecionado != null ? Colors.green : const Color(0xFFFC2D7C)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (processoController.text.isEmpty) return;
                    
                    Navigator.pop(context); // Fecha Dialog
                    
                    setState(() {
                      _isLoading = true;
                    });
                    
                    try {
                      final novaAudiencia = AudienciaPainel(
                        id: 0, // Ignorado pelo banco
                        idProcesso: processoController.text,
                        dataAudiencia: dataController.text.isEmpty ? null : dataController.text,
                        horario: horarioController.text.isEmpty ? null : horarioController.text,
                        tipo: tipoSelecionado,
                        partes: {},
                        pontoControvertido: null,
                        lembrete: lembreteController.text.isEmpty ? null : lembreteController.text,
                        caminhoAnexo: caminhoAnexoSelecionado,
                        statusVideo: tipoSelecionado == 'Telepresencial',
                        resumoPrevia: 'Aguardando processamento com TogaEngine...',
                      );
                      
                      await _service.criarAudiencia(novaAudiencia);
                      await _carregarAudiencias(); // Atualiza a pauta
                    } catch (e) {
                      setState(() {
                        _isLoading = false;
                        _errorMessage = e.toString();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10AC84), foregroundColor: Colors.white),
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text('Erro na Sincronização\n$_errorMessage', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar Novamente'),
                style: ElevatedButton.styleFrom(backgroundColor: TogaColors.azulPetroleo, foregroundColor: Colors.white),
                onPressed: _carregarAudiencias,
              )
            ],
          ),
        ),
      );
    }

    if (_audiencias.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available, color: Colors.grey.shade400, size: 80),
            const SizedBox(height: 16),
            const Text('Nenhuma audiência marcada para hoje.', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          ..._audiencias.map((audiencia) => TogaAudienciaCard(audiencia: audiencia)).toList(),
          const SizedBox(height: 48), // Espaço para não invadir o footer
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 20, color: Colors.black87),
              const SizedBox(width: 8),
              Text(
                'Data Base: ${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}  |  Total: ${_audiencias.length}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.green.shade200)),
            child: const Row(
              children: [
                Icon(Icons.circle, color: Color(0xFF10AC84), size: 10),
                SizedBox(width: 6),
                Text('Python Online', style: TextStyle(color: Color(0xFF10AC84), fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return const Center(
      child: Text('TogaMind+ | Monitoramento Local RAG (Porta 8000)', style: TextStyle(color: Colors.grey, fontSize: 13)),
    );
  }
}
