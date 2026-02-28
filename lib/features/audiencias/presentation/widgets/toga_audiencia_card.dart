import 'package:flutter/material.dart';
import '../../data/models/audiencia_painel_model.dart';
import '../toga_ata_editor_view.dart';
import 'package:path/path.dart' as p;

class TogaAudienciaCard extends StatelessWidget {
  final AudienciaPainel audiencia;

  const TogaAudienciaCard({super.key, required this.audiencia});

  @override
  Widget build(BuildContext context) {
    // Verde Gabinete (0xFF10AC84) para audiências com Vídeo ou padrão
    final Color borderColor = audiencia.statusVideo ? const Color(0xFF10AC84) : Colors.grey.shade300;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: borderColor, width: 2.0),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Color(0xFF10AC84), size: 24),
                    const SizedBox(width: 8),
                    Text(
                      audiencia.horario ?? 'Horário Indefinido',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10AC84).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF10AC84)),
                  ),
                  child: Text(
                    audiencia.tipo.toUpperCase(),
                    style: const TextStyle(color: Color(0xFF0C8A69), fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Text(
              'CNJ: ${audiencia.idProcesso}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 12),
            
            // Exibição da Previa gerada pela IA
            if (audiencia.resumoPrevia != null && audiencia.resumoPrevia!.isNotEmpty)
              Text(
                audiencia.resumoPrevia!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              
            if (audiencia.pontoControvertido != null && audiencia.pontoControvertido!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4), // Verde muito claro
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF10AC84).withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: Color(0xFF10AC84), size: 18),
                        SizedBox(width: 6),
                        Text('Ponto Controvertido (RAG ScanNut):', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0C8A69), fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(audiencia.pontoControvertido!, style: const TextStyle(color: Colors.black87, height: 1.3, fontSize: 13)),
                  ],
                ),
              ),
            ],
            if (audiencia.lembrete != null && audiencia.lembrete!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.push_pin, color: Colors.orange, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Lembrete: ${audiencia.lembrete!}',
                        style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (audiencia.caminhoAnexo != null && audiencia.caminhoAnexo!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.picture_as_pdf, color: Colors.blue, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Anexo: ${p.basename(audiencia.caminhoAnexo!)}',
                        style: const TextStyle(fontSize: 13, color: Colors.blue, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  audiencia.statusVideo ? Icons.videocam : Icons.videocam_off,
                  color: audiencia.statusVideo ? const Color(0xFF10AC84) : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  audiencia.statusVideo ? 'Sala Virtual Ativa (Balcão)' : 'Audiência 100% Presencial',
                  style: TextStyle(
                    color: audiencia.statusVideo ? const Color(0xFF0C8A69) : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                icon: const Icon(Icons.meeting_room, color: Color(0xFF10AC84)),
                label: const Text('Entrar na Sala Digital (Gerar Ata)', style: TextStyle(color: Color(0xFF10AC84), fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF10AC84).withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TogaAtaEditorView(audiencia: audiencia)),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
