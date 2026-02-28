import 'package:flutter/material.dart';

class TogaErrorTraceWidget extends StatelessWidget {
  final String message;
  final String trace;

  const TogaErrorTraceWidget({super.key, required this.message, required this.trace});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // Ergonomia obrigatória
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.red.shade50, // Feedback visual de erro
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ERRO: $message",
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text("TRACE TÉCNICO:", style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(top: 8),
              width: double.infinity,
              color: Colors.black12,
              child: SelectableText( // Permitir que o Juiz copie o Log se desejar
                trace,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            const SizedBox(height: 80), // Proteção contra overflow e rodapés
          ],
        ),
      ),
    );
  }
}
