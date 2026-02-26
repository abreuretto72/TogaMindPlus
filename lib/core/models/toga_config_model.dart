class TogaConfigModel {
  final String activeModel;
  final String apiVersion;
  final bool maintenanceMode;
  final String systemMessage;

  TogaConfigModel({
    required this.activeModel,
    required this.apiVersion,
    required this.maintenanceMode,
    required this.systemMessage,
  });

  factory TogaConfigModel.fromJson(Map<String, dynamic> json) {
    return TogaConfigModel(
      activeModel: json['active_model'] ?? 'gemini-3-flash',
      apiVersion: json['api_version'] ?? 'v1',
      maintenanceMode: json['maintenance_mode'] ?? false,
      systemMessage: json['system_message'] ?? 'Servidor TogaMind+ Operacional',
    );
  }

  // Fallback defaults if network fails
  factory TogaConfigModel.fallback() {
    return TogaConfigModel(
      activeModel: 'gemini-3-flash',
      apiVersion: 'v1',
      maintenanceMode: false,
      systemMessage: 'Servidor Operacional (Fallback Local)',
    );
  }
}
