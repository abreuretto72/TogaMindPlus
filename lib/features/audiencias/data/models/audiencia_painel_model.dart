class AudienciaPainel {
  final int id;
  final String idProcesso;
  final String? dataAudiencia;
  final String? horario;
  final String tipo;
  final Map<String, dynamic>? partes;
  final String? pontoControvertido;
  final bool statusVideo;
  final String? resumoPrevia;
  final bool? historicoUtilizado;
  final String? lembrete;
  final String? caminhoAnexo;

  AudienciaPainel({
    required this.id,
    required this.idProcesso,
    this.dataAudiencia,
    required this.horario,
    required this.tipo,
    required this.partes,
    this.pontoControvertido,
    required this.statusVideo,
    this.resumoPrevia,
    this.historicoUtilizado,
    this.lembrete,
    this.caminhoAnexo,
  });

  factory AudienciaPainel.fromJson(Map<String, dynamic> json) {
    return AudienciaPainel(
      id: json['id'] as int,
      idProcesso: json['id_processo'] as String,
      dataAudiencia: json['data_audiencia'] as String?,
      horario: json['horario'] as String?,
      tipo: json['tipo'] as String,
      partes: json['partes'] != null ? Map<String, dynamic>.from(json['partes']) : null,
      pontoControvertido: json['ponto_controvertido'] as String?,
      statusVideo: json['status_video'] == 1,
      resumoPrevia: json['resumo_previa'] as String?,
      historicoUtilizado: json['historico_utilizado'] as bool?,
      lembrete: json['lembrete'] as String?,
      caminhoAnexo: json['caminho_anexo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_processo': idProcesso,
      'data_audiencia': dataAudiencia,
      'horario': horario,
      'tipo': tipo,
      'partes': partes,
      'ponto_controvertido': pontoControvertido,
      'status_video': statusVideo,
      'resumo_previa': resumoPrevia,
      'historico_utilizado': historicoUtilizado,
      'lembrete': lembrete,
      'caminho_anexo': caminhoAnexo,
    };
  }
}
