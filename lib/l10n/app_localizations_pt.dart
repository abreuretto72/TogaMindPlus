// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get app_title => 'TogaMind+';

  @override
  String get dashboard_welcome => 'Assistente de Gabinete';

  @override
  String get action_new_draft => 'Nova Minuta';

  @override
  String get action_processes => 'Processos';

  @override
  String get action_delete => 'Excluir';

  @override
  String get footer_copyright =>
      '© 2026 ScanNut Multiverso Digital | TogaMind+';

  @override
  String get url_base => 'https://multiversodigital.com.br/TogaMindPlus';

  @override
  String get draft_title => 'Elaborar Minuta';

  @override
  String get draft_process_label => 'Processo nº: 0001234-56.2026.8.26.0526';

  @override
  String get draft_hint => 'Comece a digitar a fundamentação...';

  @override
  String get action_save => 'Salvar Minuta';

  @override
  String get msg_success => 'Minuta salva com sucesso!';

  @override
  String get msg_error => 'Erro ao salvar a minuta.';

  @override
  String get error_network => 'Erro de conexão. Verifique sua rede.';

  @override
  String get msg_analyzing => 'O Gemini 3 Flash está analisando os autos...';

  @override
  String get analysis_title => 'Análise de Processo';

  @override
  String get error_pdf => 'Erro ao carregar o arquivo PDF.';

  @override
  String get btn_upload => 'Carregar Processo PDF';

  @override
  String get result_label => 'RESUMO DO PROCESSO';

  @override
  String get msg_synced => 'Sincronizado';

  @override
  String get chat_title => 'Assistente de Gabinete';

  @override
  String get chat_hint => 'Pergunte à sua memória RAG...';

  @override
  String get btn_send => 'Enviar';

  @override
  String get error_rag => 'Erro de conexão com o cérebro RAG.';

  @override
  String get error_access_denied => 'Acesso Negado. Credenciais inválidas.';

  @override
  String get error_session_expired => 'Sessão Expirada. Faça login novamente.';

  @override
  String get action_logout => 'Sair';

  @override
  String get action_import_token => 'Importar via Token';

  @override
  String get token_reading_label => 'Baixando Autos';

  @override
  String get token_success =>
      'Processo indexado. Você já pode fazer perguntas sobre estes autos.';

  @override
  String get token_error => 'Erro na captura ou Token expirado.';

  @override
  String get action_unlock_token => 'Desbloquear Token';

  @override
  String get token_password_label => 'Senha do Certificado';

  @override
  String get action_cancel => 'CANCELAR';

  @override
  String get action_unlock => 'DESBLOQUEAR';

  @override
  String get token_not_registered => 'Nenhum token vinculado ao seu Gabinete.';

  @override
  String get action_link_token => 'Vincular Novo Certificado';

  @override
  String get action_copy_saj => 'COPIAR PARA O SAJ';

  @override
  String get label_minuta_editor => 'Minuta de Fundamentação';

  @override
  String get msg_copied => 'Copiado para a área de transferência!';

  @override
  String get action_export_pdf => 'GERAR PDF PARA ASSINATURA';
}
