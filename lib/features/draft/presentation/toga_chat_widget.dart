import 'package:flutter/material.dart';
import 'package:toga_mind_plus/l10n/app_localizations.dart';
import 'package:toga_mind_plus/features/analysis/services/toga_analysis_service.dart';

class TogaChatWidget extends StatefulWidget {
  const TogaChatWidget({super.key});

  @override
  State<TogaChatWidget> createState() => _TogaChatWidgetState();
}

class _TogaChatWidgetState extends State<TogaChatWidget> {
  final TextEditingController _queryController = TextEditingController();
  final TogaAnalysisService _analysisService = TogaAnalysisService();
  final List<Map<String, String>> _messages = [];
  bool _isTyping = false;

  Future<void> _askToga(AppLocalizations l10n) async {
    final text = _queryController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      // Inserindo no início (índice 0) porque a lista é reverse: true
      _messages.insert(0, {"user": text});
      _isTyping = true;
      _queryController.clear();
    });

    final answer = await _analysisService.askToga(text);

    if (mounted) {
      setState(() {
        _isTyping = false;
        if (answer != null) {
          _messages.insert(0, {"toga": answer});
        } else {
          _messages.insert(0, {"toga": l10n.error_rag});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7, // 70% da tela
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHandle(), // Barra de arraste
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder( 
              reverse: true, // Inicia no final da conversa
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          if (_isTyping) const LinearProgressIndicator(color: Color(0xFF005B70)),
          _buildInputArea(l10n),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, String> msg) {
    final bool isUser = msg.containsKey("user");
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFFF1F5F9) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUser ? Colors.transparent : const Color(0xFFFC2D7C).withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          isUser ? msg["user"]! : msg["toga"]!,
          style: TextStyle(
            fontSize: 14,
            color: isUser ? Colors.black87 : const Color(0xFF005B70),
            fontWeight: isUser ? FontWeight.normal : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.only(
        top: 8.0,
        bottom: MediaQuery.of(context).viewInsets.bottom, // Proteção contra teclado
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _queryController,
              decoration: InputDecoration(
                hintText: l10n.chat_hint, 
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _askToga(l10n),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF005B70)), // Azul Petróleo
            onPressed: () => _askToga(l10n),
          ),
        ],
      ),
    );
  }
}
