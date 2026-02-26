import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:toga_mind_plus/core/toga_colors.dart';
import 'package:toga_mind_plus/l10n/app_localizations.dart';
import 'package:toga_mind_plus/features/analysis/services/toga_analysis_service.dart';

class TogaTokenImportView extends StatefulWidget {
  const TogaTokenImportView({super.key});

  @override
  State<TogaTokenImportView> createState() => _TogaTokenImportViewState();
}

class _TogaTokenImportViewState extends State<TogaTokenImportView> {
  final TextEditingController _processoController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  
  bool _isLoadingStatus = true;
  bool _isLoadingAction = false;
  
  bool _isRegistered = false;
  bool _isUnlocked = false;
  
  String? _resumoGerado;
  
  PlatformFile? _selectedPfx;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }
  
  @override
  void dispose() {
    _processoController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    final status = await TogaAnalysisService.getTokenStatus();
    if (mounted) {
      setState(() {
        _isRegistered = status['registered'] ?? false;
        _isUnlocked = status['unlocked'] ?? false;
        _isLoadingStatus = false;
      });
    }
  }

  Future<void> _registerPfxFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pfx', 'p12'],
      withData: true,
    );
    
    if (result != null && result.files.isNotEmpty) {
      setState(() => _isLoadingAction = true);
      final file = result.files.first;
      
      final success = await TogaAnalysisService.registerToken(
        pfxBytes: file.bytes!,
        pfxName: file.name,
      );
      
      if (!mounted) return;
      
      setState(() => _isLoadingAction = false);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Token salvo fisicamente com sucesso."), backgroundColor: Colors.green),
        );
        _checkStatus();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Falha ao salvar token."), backgroundColor: Color(0xFFFC2D7C)),
        );
      }
    }
  }

  Future<void> _handleUnlock() async {
    if (_senhaController.text.isEmpty) return;
    
    setState(() => _isLoadingAction = true);
    final success = await TogaAnalysisService.unlockToken(_senhaController.text);
    if (!mounted) return;
    setState(() => _isLoadingAction = false);
    
    if (success) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Token desbloqueado nesta sessão."), backgroundColor: Colors.green),
      );
      _checkStatus();
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Senha incorreta."), backgroundColor: Color(0xFFFC2D7C)),
      );
    }
  }

  Future<void> _importarProcesso() async {
    if (_processoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Informe o número do processo."), backgroundColor: Color(0xFFFC2D7C)),
      );
      return;
    }

    setState(() => _isLoadingAction = true);
    
    final l10n = AppLocalizations.of(context);
    
    try {
      final result = await TogaAnalysisService.importProcessByToken(
        processNumber: _processoController.text,
      );

      if (!mounted) return;
      setState(() => _isLoadingAction = false);

      if (result != null && result['success'] == true) {
        setState(() {
           _resumoGerado = result['summary'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.token_success ?? "Processo indexado."),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text(l10n?.token_error ?? "Falha na importação."),
            backgroundColor: const Color(0xFFFC2D7C),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingAction = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro: $e"),
          backgroundColor: const Color(0xFFFC2D7C),
        ),
      );
    }
  }
  
  void _showUnlockModal() {
    _senhaController.clear();
    showDialog(
      context: context,
      barrierDismissible: !_isLoadingAction,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateModal) {
          return AlertDialog(
            title: const Text('Desbloquear Token TJSP', style: TextStyle(color: TogaColors.azulPetroleo)),
            content: Container(
              constraints: const BoxConstraints(maxWidth: 300),
              child: TextField(
                controller: _senhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha do Certificado',
                  prefixIcon: Icon(Icons.lock, color: TogaColors.azulPetroleo),
                ),
                onSubmitted: (_) async {
                  setStateModal(() => _isLoadingAction = true);
                  await _handleUnlock();
                  if (mounted && _isUnlocked) Navigator.pop(context);
                  setStateModal(() => _isLoadingAction = false);
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: _isLoadingAction ? null : () => Navigator.pop(context),
                child: const Text('CANCELAR', style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                onPressed: _isLoadingAction ? null : () async {
                  setStateModal(() => _isLoadingAction = true);
                  await _handleUnlock();
                  if (mounted && _isUnlocked) Navigator.pop(context);
                  setStateModal(() => _isLoadingAction = false);
                },
                style: ElevatedButton.styleFrom(backgroundColor: TogaColors.azulPetroleo, foregroundColor: Colors.white),
                child: _isLoadingAction 
                   ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                   : const Text('DESBLOQUEAR'),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildResumoAutomacao(String resumo) {
    // Quebrar o resumo em pontos usando expressões regulares comuns do Gemini:
    // Ponto 1: Ou numerado (1. , 2.) ou com asteriscos (* , -)
    final linhas = resumo.split('\n').where((linha) => linha.trim().isNotEmpty).toList();

    return Card(
      elevation: 4,
      color: const Color(0xFFF5F5F5),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFF005B70), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Resumo de Entrada (IA)', 
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF005B70))),
            const Divider(),
            ...linhas.map((linha) => _buildPontoInterativo(linha, _processoController.text)),
          ],
        ),
      ),
    );
  }

  Widget _buildPontoInterativo(String textoPonto, String processoNumero) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(textoPonto, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.chat_bubble_outline, color: Color(0xFF005B70), size: 18),
      onTap: () {
        Navigator.pushNamed(context, '/chat', arguments: {
          'processo': processoNumero,
          'pergunta_inicial': "Explique com mais detalhes este ponto do resumo: $textoPonto"
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l10n.action_import_token),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: TogaColors.azulPetroleo,
        bottom: _isLoadingAction
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4.0),
                child: LinearProgressIndicator(color: TogaColors.azulPetroleo, backgroundColor: Colors.white),
              )
            : null,
      ),
      body: Center(
        child: _isLoadingStatus 
        ? const CircularProgressIndicator(color: TogaColors.azulPetroleo)
        : SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: _buildCentralContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildCentralContent() {
    if (!_isRegistered) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.vpn_key_off, size: 64, color: Colors.grey),
          const SizedBox(height: 24),
          const Text(
            "Nenhum Certificado Vinculado",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: TogaColors.azulPetroleo),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            "Seu gabinete ainda não possui token PFX físico configurado no cofre.",
            style: TextStyle(color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isLoadingAction ? null : _registerPfxFile,
              icon: _isLoadingAction ? const SizedBox.shrink() : const Icon(Icons.add_link),
              label: _isLoadingAction 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("Vincular Novo Certificado", style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(backgroundColor: TogaColors.azulPetroleo, foregroundColor: Colors.white),
            )
          )
        ],
      );
    }
    
    if (!_isUnlocked) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline, size: 64, color: Colors.orange),
          const SizedBox(height: 24),
          const Text(
            "Sessão Bloqueada",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: TogaColors.azulPetroleo),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            "O seu certificado PFX encontra-se fisicamente guardado. Desbloqueie-o para uso temporário na memória.",
            style: TextStyle(color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _showUnlockModal,
              icon: const Icon(Icons.lock_open),
              label: const Text("Desbloquear Sessão", style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(backgroundColor: TogaColors.azulPetroleo, foregroundColor: Colors.white),
            )
          )
        ],
      );
    }

    // Quando Is Registered e Is Unlocked (Gabinete Operacional para Download)
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.vpn_key, size: 64, color: Colors.green),
        const SizedBox(height: 24),
        const Text(
          "Token Ativo e Operacional",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: TogaColors.azulPetroleo),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          "O certificado do Tribunal está em memória RAM pronta para download do ESAJ.",
          style: TextStyle(color: Colors.black54),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        TextField(
          controller: _processoController,
          decoration: const InputDecoration(
            labelText: "Número do Processo (TJSP)",
            prefixIcon: Icon(Icons.gavel),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: TogaColors.azulPetroleo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _isLoadingAction ? null : _importarProcesso,
            icon: _isLoadingAction 
              ? const SizedBox.shrink() 
              : const Icon(Icons.cloud_download, color: Colors.white),
            label: _isLoadingAction
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text("Baixar e Importar Autos", style: TextStyle(fontSize: 16)),
          ),
        ),
        if (_resumoGerado != null) ...[
          const SizedBox(height: 32),
          _buildResumoAutomacao(_resumoGerado!),
        ]
      ],
    );
  }
}
