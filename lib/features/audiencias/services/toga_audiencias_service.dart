import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/audiencia_painel_model.dart';
import 'package:toga_mind_plus/core/services/toga_config_service.dart';

class TogaAudienciasService {
  Future<List<AudienciaPainel>> listarAudiencias() async {
    const String endpoint = 'http://127.0.0.1:8000';
    final url = Uri.parse('$endpoint/audiencias');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((item) => AudienciaPainel.fromJson(item)).toList();
      } else {
        throw Exception('Erro no servidor HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Falha de conexão com a API de Audiências: $e');
    }
  }

  Future<void> criarAudiencia(AudienciaPainel audiencia) async {
    const String endpoint = 'http://127.0.0.1:8000';
    final url = Uri.parse('$endpoint/audiencias');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(audiencia.toJson()..remove('id')), // Remove pseudo id
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Erro ao criar audiência: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Falha ao adicionar audiência no Motor Python: $e');
    }
  }

  Future<Map<String, dynamic>> prepararAudiencia(String processoId, String caminhoPdf) async {
    const String endpoint = 'http://127.0.0.1:8000';
    try {
      final response = await http.post(
        Uri.parse('$endpoint/audiencia/preparar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'processo_id': processoId,
          'caminho_pdf': caminhoPdf,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception("Erro ao processar RAG local (Engine 8000)");
      }
    } catch (e) {
      print("Erro de Conexão Engine: $e");
      rethrow;
    }
  }
}
