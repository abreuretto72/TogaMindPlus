import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:convert';
import 'package:toga_mind_plus/core/services/toga_auth_service.dart';

class TogaAnalysisService {
  // Endpoint para testes locais e operação offline (127.0.0.1)
  static const String _analysisUrl = 'http://127.0.0.1:8000/analyze';
  static const String _ragUrl = 'http://127.0.0.1:8000/save-rag';
  static const String _syncUrl = 'http://127.0.0.1:8000/sync-rag';
  static const String _askUrl = 'http://127.0.0.1:8000/ask-toga';

  /// Seleciona o PDF do computador do juiz
  Future<PlatformFile?> pickProcessPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true, // Necessário para Flutter Web
    );

    return result?.files.first;
  }

  void _handleUnauthorized(int statusCode) {
    if (statusCode == 401) {
      TogaAuthService.logout();
      throw Exception('401_UNAUTHORIZED');
    }
  }

  /// Envia o PDF para o Gemini 3 Flash via Backend
  Future<String?> sendToAI(Uint8List fileBytes, String fileName) async {
    try {
      final String? judgeId = await TogaAuthService.getActiveJudgeId();
      
      var request = http.MultipartRequest('POST', Uri.parse(_analysisUrl));
      
      // Enviando header judge_id
      request.headers['judge_id'] = judgeId ?? 'anonimo';

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      _handleUnauthorized(response.statusCode);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['analysis'] as String?;
      }
      return null;
    } catch (e) {
      if (e.toString().contains('401_UNAUTHORIZED')) rethrow;
      return null;
    }
  }

  /// Envia conteúdo para o cofre RAG do Juiz
  Future<bool> syncWithRAG({
    required String contentType,
    required String title,
    required String content,
  }) async {
    try {
      final String? judgeId = await TogaAuthService.getActiveJudgeId();
      
      final response = await http.post(
        Uri.parse(_syncUrl),
        headers: {
          "Content-Type": "application/json",
          "judge_id": judgeId ?? 'anonimo'
        },
        body: jsonEncode({
          "content": content
        }),
      );
      
      _handleUnauthorized(response.statusCode);
      return response.statusCode == 200;
    } catch (e) {
      if (e.toString().contains('401_UNAUTHORIZED')) rethrow;
      return false;
    }
  }

  /// Consulta o Cérebro
  Future<String?> askToga(String query) async {
    try {
      final String? judgeId = await TogaAuthService.getActiveJudgeId();
      
      final response = await http.post(
        Uri.parse(_askUrl),
        headers: {
          "Content-Type": "application/json",
          "judge_id": judgeId ?? 'anonimo'
        },
        body: jsonEncode({"query": query}),
      );

      _handleUnauthorized(response.statusCode);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['answer'] as String?;
      }
      return null;
    } catch (e) {
      if (e.toString().contains('401_UNAUTHORIZED')) rethrow;
      return null;
    }
  }

  /// Verifica se o token já está registrado e desbloqueado
  static Future<Map<String, dynamic>> getTokenStatus() async {
    try {
      final String? judgeId = await TogaAuthService.getActiveJudgeId();
      if (judgeId == null) return {'registered': false, 'unlocked': false};

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/token-status'),
        headers: {'judge_id': judgeId},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'registered': false, 'unlocked': false};
    } catch (e) {
      return {'registered': false, 'unlocked': false};
    }
  }

  /// Vincula o certificado .pfx fisicamente ao Vault do juiz
  static Future<bool> registerToken({
    required Uint8List pfxBytes,
    required String pfxName,
  }) async {
    try {
      final String? judgeId = await TogaAuthService.getActiveJudgeId();
      if (judgeId == null) return false;

      var request = http.MultipartRequest('POST', Uri.parse('http://127.0.0.1:8000/register-token'));
      request.headers['judge_id'] = judgeId;

      request.files.add(
        http.MultipartFile.fromBytes(
          'certificate',
          pfxBytes,
          filename: pfxName,
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 401) {
        TogaAuthService.logout();
        throw Exception('401_UNAUTHORIZED');
      }

      return response.statusCode == 200;
    } catch (e) {
      if (e.toString().contains('401_UNAUTHORIZED')) rethrow;
      return false;
    }
  }

  /// Desbloqueia a sessão do token mantendo a senha em memória RAM
  static Future<bool> unlockToken(String password) async {
    try {
      final String? judgeId = await TogaAuthService.getActiveJudgeId();
      if (judgeId == null) return false;

      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/unlock-token'),
        headers: {
          'Content-Type': 'application/json',
          'judge_id': judgeId,
        },
        body: jsonEncode({"password": password}),
      );

      if (response.statusCode == 401) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        if (body['detail'] == 'Senha do certificado incorreta.') {
           return false;
        }
        TogaAuthService.logout();
        throw Exception('401_UNAUTHORIZED');
      }

      return response.statusCode == 200;
    } catch (e) {
      if (e.toString().contains('401_UNAUTHORIZED')) rethrow;
      return false;
    }
  }

  /// Importa processo usando o Token já registrado e desbloqueado
  static Future<Map<String, dynamic>?> importProcessByToken({
    required String processNumber,
  }) async {
    try {
      final String? judgeId = await TogaAuthService.getActiveJudgeId();
      if (judgeId == null) return null;

      var request = http.MultipartRequest('POST', Uri.parse('http://127.0.0.1:8000/import-process'));
      request.headers['judge_id'] = judgeId;

      request.fields['process_number'] = processNumber;

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 401) {
        TogaAuthService.logout();
        throw Exception('401_UNAUTHORIZED');
      }

      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        return {
           'success': true,
           'summary': body['summary'],
        };
      }
      return {'success': false, 'summary': null};
    } catch (e) {
      if (e.toString().contains('401_UNAUTHORIZED')) rethrow;
      return null;
    }
  }
}
