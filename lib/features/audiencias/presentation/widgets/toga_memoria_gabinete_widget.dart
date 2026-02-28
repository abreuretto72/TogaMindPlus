import 'package:flutter/material.dart';

class TogaMemoriaGabineteWidget extends StatelessWidget {
  final bool usandoHistorico;

  const TogaMemoriaGabineteWidget({super.key, required this.usandoHistorico});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: usandoHistorico ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(bottom: 16), // Espaçamento orgânico
        decoration: BoxDecoration(
          color: const Color(0xFF10AC84).withValues(alpha: 0.1), // Verde Sucesso com Alpha protocolar
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Ocupa apenas o necessário
          children: [
            const Icon(Icons.psychology, color: Color(0xFF10AC84), size: 18),
            const SizedBox(width: 8),
            Text(
              "Contexto de decisões anteriores aplicado",
              style: TextStyle(fontSize: 13, color: Colors.green.shade800, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
