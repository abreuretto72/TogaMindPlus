import 'package:shared_preferences/shared_preferences.dart';

class TogaStorageService {
  // Chave interna seguindo o prefixo do domínio
  static const String _draftKey = 'toga_current_draft';

  // Salvar minuta localmente (Pilar: Imunidade a Erros)
  static Future<bool> saveDraft(String content) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_draftKey, content);
    } catch (e) {
      // Feedback de erro será tratado na UI (Fundo Vermelho)
      return false;
    }
  }

  // Recuperar última minuta salva
  static Future<String?> loadDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_draftKey);
    } catch (e) {
      return null;
    }
  }

  // Limpar minuta (Ex: após protocolar)
  static Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey);
  }
}
