import 'package:flutter/material.dart';

class TogaPosAudienciaView extends StatelessWidget {
  final String destinoArquivo;

  const TogaPosAudienciaView({super.key, required this.destinoArquivo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView( 
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 80.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF10AC84), size: 120), // Toga Verde Sucesso
                const SizedBox(height: 32),
                const Text(
                  "Audiência Finalizada com Sucesso!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      const Text("Documento DOCX Oficial disponível em:", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(destinoArquivo, style: const TextStyle(fontSize: 16, color: Colors.black87), textAlign: TextAlign.center),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text("O processo foi removido da fila local de audiências do dia.", style: TextStyle(color: Color(0xFF10AC84), fontStyle: FontStyle.italic)),
                const SizedBox(height: 48),
                SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Voltar para Pauta", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10AC84),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                ),
                const SizedBox(height: 64), 
              ],
            ),
          ),
        ),
      ),
    );
  }
}
