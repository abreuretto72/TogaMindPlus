import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TogaAuthService {
  static const String _userKey = 'active_judge_id';
  static const String _baseUrl = 'http://127.0.0.1:8000';

  /// Registra um novo juiz localmente
  static Future<bool> registerLocal(String judgeId, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"judge_id": judgeId, "password": password}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Autentica o juiz contra a bolha local
  static Future<bool> loginLocal(String judgeId, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"judge_id": judgeId, "password": password}),
      );
      if (response.statusCode == 200) {
        await saveSession(judgeId);
        return true;
      }
      return false;
    } catch (e) {
      return false;
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
