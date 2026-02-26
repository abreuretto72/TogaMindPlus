import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:toga_mind_plus/core/models/toga_config_model.dart';
import 'package:toga_mind_plus/l10n/app_localizations.dart';

class TogaConfigService {
  static const String configUrl = 'http://127.0.0.1:8000/config.json';

  static Future<TogaConfigModel> fetchConfig({AppLocalizations? l10n}) async {
    try {
      final response = await http.get(Uri.parse(configUrl)).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return TogaConfigModel.fromJson(decoded);
      } else {
        return _getFallbackWithError(l10n);
      }
    } catch (e) {
      return _getFallbackWithError(l10n);
    }
  }

  static TogaConfigModel _getFallbackWithError(AppLocalizations? l10n) {
    if (l10n != null) {
      return TogaConfigModel(
        activeModel: 'gemini-3-flash',
        apiVersion: 'v1',
        maintenanceMode: false,
        systemMessage: l10n.error_network,
      );
    }
    return TogaConfigModel.fallback();
  }
}
