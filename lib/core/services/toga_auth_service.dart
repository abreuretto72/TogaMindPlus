import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TogaAuthService {
  static const String _userKey = 'active_judge_id';
  static const String _baseUrl = 'http://127.0.0.1:8000';

  static Future<void> _logAudit(String action, String details) async {
    try {
      final logFile = File("TogaMind_audit.log");
      final timestamp = DateTime.now().toIso8601String();
      await logFile.writeAsString("[$timestamp] $action: $details\n", mode: FileMode.append);
    } catch (_) {} 
  }

  /// Registra um novo juiz localmente
  static Future<Map<String, dynamic>> registerLocal(String judgeId, String password) async {
    await _logAudit("REGISTER_API", "Iniciando tentativa de registro para judge_id: $judgeId");
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"judge_id": judgeId, "password": password}),
      ).timeout(const Duration(seconds: 10));

      await _logAudit("REGISTER_API_RESPONSE", "Status: ${response.statusCode} - Body: ${response.body}");

      if (response.statusCode == 200) {
        return {"success": true, "message": "Criado com sucesso"};
      } else {
        final body = jsonDecode(response.body);
        return {"success": false, "message": body['detail'] ?? "Erro do servidor."};
      }
    } catch (e) {
      await _logAudit("REGISTER_API_ERROR", "Falha catastrófica: $e");
      return {"success": false, "message": "Falha de Conexão com o Motor de IA na porta 8000. O TogaEngine.exe está rodando?"};
    }
  }

  /// Autentica o juiz contra a bolha local
  static Future<Map<String, dynamic>> loginLocal(String judgeId, String password) async {
    await _logAudit("LOGIN_API", "Iniciando tentativa de login para judge_id: $judgeId");
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"judge_id": judgeId, "password": password}),
      ).timeout(const Duration(seconds: 10));

      await _logAudit("LOGIN_API_RESPONSE", "Status: ${response.statusCode} - Body: ${response.body}");

      if (response.statusCode == 200) {
        await saveSession(judgeId);
        return {"success": true, "message": "Autenticado"};
      } else {
        final body = jsonDecode(response.body);
        return {"success": false, "message": body['detail'] ?? "Senha incorreta ou usuário não encontrado."};
      }
    } catch (e) {
      await _logAudit("LOGIN_API_ERROR", "Falha catastrófica: $e");
      return {"success": false, "message": "Falha de Conexão com o Motor de IA Local: $e"};
    }
  }

  /// Salva a sessão do juiz após o login
  static Future<void> saveSession(String judgeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, judgeId);
  }

  /// Recupera o ID para as chamadas de API (Headers)
  static Future<String?> getActiveJudgeId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKey);
  }

  /// Logout: Limpa a sessão e a memória temporária
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  /// Verifica se há um juiz logado para proteção de rotas
  static Future<bool> isAuthenticated() async {
    final id = await getActiveJudgeId();
    return id != null && id.isNotEmpty;
  }
}
