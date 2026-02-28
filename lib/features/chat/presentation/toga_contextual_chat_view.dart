import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toga_mind_plus/l10n/app_localizations.dart';
import 'package:toga_mind_plus/core/toga_colors.dart';
import 'package:toga_mind_plus/core/services/toga_auth_service.dart';
import 'package:toga_mind_plus/core/utils/toga_anonymizer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';

class TogaContextualChatView extends StatefulWidget {
  const TogaContextualChatView({super.key});

  @override
  State<TogaContextualChatView> createState() => _TogaContextualChatViewState();
}

class _TogaContextualChatViewState extends State<TogaContextualChatView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  String? _processoNumero;
  bool _isInit = false;
  bool _isLoading = false;
  
  final List<Map<String, dynamic>> _messages = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _processoNumero = args['processo'];
        final String perguntaInicial = args['pergunta_inicial'];
        
        _sendMessage(perguntaInicial);
      }
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _processoNumero == null) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text, 'pagina': -1, 'arquivo': ''});
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    FocusScope.of(context).unfocus();

    try {
      final String? judgeId = await TogaAuthService.getActiveJudgeId();
      if (judgeId == null) throw Exception('401_UNAUTHORIZED');

      final anonResult = TogaAnonymizer.anonymizeWithMap(text);

      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/chat-contextual'),
        headers: {
          'Content-Type': 'application/json',
          'judge_id': judgeId,
        },
        body: jsonEncode({
          'query': anonResult.anonymizedText,
          'processo_numero': _processoNumero,
        }),
      );

      if (response.statusCode == 401) {
        TogaAuthService.logout();
        throw Exception('401_UNAUTHORIZED');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        // Reverte as tags da IA para o texto original usando o mapeamento
        final respostaRevertida = TogaAnonymizer.deanonymize(data['resposta'], anonResult.mapping);
        
        setState(() {
          _messages.add({
            'sender': 'ai', 
            'text': respostaRevertida,
            'pagina': data['pagina'] ?? -1,
            'arquivo': data['arquivo'] ?? '',
          });
        });
      } else {
        setState(() {
          _messages.add({'sender': 'ai', 'text': AppLocalizations.of(context)?.error_rag ?? 'Erro.', 'pagina': -1, 'arquivo': ''});
        });
      }
    } catch (e) {
      if (e.toString().contains('401_UNAUTHORIZED')) rethrow;
      setState(() {
        _messages.add({'sender': 'ai', 'text': AppLocalizations.of(context)?.error_rag ?? 'Erro.', 'pagina': -1, 'arquivo': ''});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  String _sanitizeForUI(String text) {
    return text.trim().replaceAll('```markdown', '').replaceAll('```', '');
  }

  String _sanitizeForPDF(String text) {
    return text
        .replaceAll(RegExp(r'```[a-z]*'), '')
        .replaceAll('```', '')
        .trim();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Fundo Gelo
      appBar: AppBar(
        title: Text('Processo $_processoNumero'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: TogaColors.azulPetroleo,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_isLoading)
               const LinearProgressIndicator(color: TogaColors.azulPetroleo, backgroundColor: Colors.white),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                reverse: true,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[_messages.length - 1 - index];
                  final isUser = msg['sender'] == 'user';
                  final text = msg['text'] as String;
                  final pagina = msg['pagina'] as int;
                  final arquivo = msg['arquivo'] as String;
                  
                  final cleanText = isUser ? text : _sanitizeForUI(text);
                  
                  return _buildMessageBubble(cleanText, isUser, pagina, arquivo, text); // Passando raw_text pro _gerarMinuta 
                },
              ),
            ),
            _buildMessageInput(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String displayString, bool isUser, int pagina, String arquivo, String rawText) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUser ? Colors.white : TogaColors.azulPetroleo.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(0),
          ),
          border: isUser ? null : Border.all(color: const Color(0xFFFC2D7C), width: 1.5), // Magenta border for AI
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isUser 
             ? Text(
                 displayString,
                 style: TextStyle(
                   color: Colors.black87,
                   fontSize: 15,
                   height: 1.4,
                 ),
               )
             : MarkdownBody(
                 data: displayString,
                 selectable: true,
                 styleSheet: MarkdownStyleSheet(
                   p: TextStyle(color: TogaColors.azulPetroleo, fontSize: 15, height: 1.4),
                   h3: TextStyle(color: TogaColors.azulPetroleo, fontSize: 16, fontWeight: FontWeight.bold),
                   strong: TextStyle(color: TogaColors.azulPetroleo, fontWeight: FontWeight.bold),
                   tableBody: TextStyle(color: TogaColors.azulPetroleo, fontSize: 14),
                 ),
               ),
            if (!isUser) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  if (pagina > 0 && arquivo.isNotEmpty) _buildBotaoCitacao(pagina, arquivo),
                  _buildBotaoMinuta(rawText),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildBotaoCitacao(int pagina, String caminhoPdf) {
    return ActionChip(
      avatar: const Icon(Icons.picture_as_pdf, size: 16, color: Colors.white),
      label: Text('Ver na pág. $pagina', style: const TextStyle(color: Colors.white)),
      backgroundColor: const Color(0xFF005B70), // Azul Petróleo
      onPressed: () {
        Navigator.pushNamed(context, '/pdf_viewer', arguments: {
          'path': caminhoPdf,
          'page': pagina,
        });
      },
    );
  }

  Widget _buildBotaoMinuta(String pontoDecisao) {
    return ActionChip(
      avatar: const Icon(Icons.edit_document, size: 16, color: Colors.white),
      label: const Text('Gerar Minuta', style: TextStyle(color: Colors.white)),
      backgroundColor: const Color(0xFFFC2D7C), // Magenta para ação gerativa
      onPressed: () => _gerarMinuta(pontoDecisao),
    );
  }

  Future<void> _gerarMinuta(String pontoDecisao) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: TogaColors.azulPetroleo)),
    );

    try {
      final String? judgeId = await TogaAuthService.getActiveJudgeId();
      if (judgeId == null) throw Exception('401_UNAUTHORIZED');

      final anonResult = TogaAnonymizer.anonymizeWithMap(_sanitizeForPDF(pontoDecisao));

      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/gerar-minuta'),
        headers: {
          'Content-Type': 'application/json',
          'judge_id': judgeId,
        },
        body: jsonEncode({
          'ponto_decisao': anonResult.anonymizedText,
          'processo_numero': _processoNumero,
        }),
      );

      if (mounted && Navigator.canPop(context)) Navigator.pop(context); // Close loading

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        // Reverte as tags da IA para o texto original no gerador de minuta
        final minutaRevertida = TogaAnonymizer.deanonymize(data['minuta'], anonResult.mapping);
        if (mounted) _mostrarEditorMinuta(minutaRevertida);
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)?.error_rag ?? 'Erro.')));
      }
    } catch (e) {
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)?.error_rag ?? 'Erro.')));
    }
  }

  void _mostrarEditorMinuta(String textoGerado) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: _buildEditorMinuta(textoGerado),
        );
      },
    );
  }

  Widget _buildEditorMinuta(String textoGerado) {
    final TextEditingController minutaController = TextEditingController(text: textoGerado);
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            maxLines: 10,
            controller: minutaController,
            decoration: InputDecoration(
              labelText: l10n.label_minuta_editor,
              alignLabelWithHint: true,
              border: const OutlineInputBorder(),
              focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFFC2D7C), width: 2)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/pdf_viewer', arguments: {
                    'conteudo': minutaController.text,
                  });
                },
                icon: const Icon(Icons.picture_as_pdf),
                label: Text(l10n.action_export_pdf),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: minutaController.text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.msg_copied), backgroundColor: Colors.green),
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.copy),
                label: Text(l10n.action_copy_saj),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TogaColors.azulPetroleo,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 12 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: TogaColors.azulPetroleo.withValues(alpha: 0.2)),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: l10n.chat_hint,
                  border: InputBorder.none,
                ),
                onSubmitted: (value) => _sendMessage(value),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: const BoxDecoration(
              color: TogaColors.azulPetroleo,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.send, color: Colors.white),
              onPressed: _isLoading ? null : () => _sendMessage(_messageController.text),
            ),
          ),
        ],
      ),
    );
  }
}
