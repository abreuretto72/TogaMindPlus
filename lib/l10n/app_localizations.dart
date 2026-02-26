import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('pt')];

  /// No description provided for @app_title.
  ///
  /// In pt, this message translates to:
  /// **'TogaMind+'**
  String get app_title;

  /// No description provided for @dashboard_welcome.
  ///
  /// In pt, this message translates to:
  /// **'Assistente de Gabinete'**
  String get dashboard_welcome;

  /// No description provided for @action_new_draft.
  ///
  /// In pt, this message translates to:
  /// **'Nova Minuta'**
  String get action_new_draft;

  /// No description provided for @action_processes.
  ///
  /// In pt, this message translates to:
  /// **'Processos'**
  String get action_processes;

  /// No description provided for @action_delete.
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get action_delete;

  /// No description provided for @footer_copyright.
  ///
  /// In pt, this message translates to:
  /// **'© 2026 ScanNut Multiverso Digital | TogaMind+'**
  String get footer_copyright;

  /// No description provided for @url_base.
  ///
  /// In pt, this message translates to:
  /// **'https://multiversodigital.com.br/TogaMindPlus'**
  String get url_base;

  /// No description provided for @draft_title.
  ///
  /// In pt, this message translates to:
  /// **'Elaborar Minuta'**
  String get draft_title;

  /// No description provided for @draft_process_label.
  ///
  /// In pt, this message translates to:
  /// **'Processo nº: 0001234-56.2026.8.26.0526'**
  String get draft_process_label;

  /// No description provided for @draft_hint.
  ///
  /// In pt, this message translates to:
  /// **'Comece a digitar a fundamentação...'**
  String get draft_hint;

  /// No description provided for @action_save.
  ///
  /// In pt, this message translates to:
  /// **'Salvar Minuta'**
  String get action_save;

  /// No description provided for @msg_success.
  ///
  /// In pt, this message translates to:
  /// **'Minuta salva com sucesso!'**
  String get msg_success;

  /// No description provided for @msg_error.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao salvar a minuta.'**
  String get msg_error;

  /// No description provided for @error_network.
  ///
  /// In pt, this message translates to:
  /// **'Erro de conexão. Verifique sua rede.'**
  String get error_network;

  /// No description provided for @msg_analyzing.
  ///
  /// In pt, this message translates to:
  /// **'O Gemini 3 Flash está analisando os autos...'**
  String get msg_analyzing;

  /// No description provided for @analysis_title.
  ///
  /// In pt, this message translates to:
  /// **'Análise de Processo'**
  String get analysis_title;

  /// No description provided for @error_pdf.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar o arquivo PDF.'**
  String get error_pdf;

  /// No description provided for @btn_upload.
  ///
  /// In pt, this message translates to:
  /// **'Carregar Processo PDF'**
  String get btn_upload;

  /// No description provided for @result_label.
  ///
  /// In pt, this message translates to:
  /// **'RESUMO DO PROCESSO'**
  String get result_label;

  /// No description provided for @msg_synced.
  ///
  /// In pt, this message translates to:
  /// **'Sincronizado'**
  String get msg_synced;

  /// No description provided for @chat_title.
  ///
  /// In pt, this message translates to:
  /// **'Assistente de Gabinete'**
  String get chat_title;

  /// No description provided for @chat_hint.
  ///
  /// In pt, this message translates to:
  /// **'Pergunte à sua memória RAG...'**
  String get chat_hint;

  /// No description provided for @btn_send.
  ///
  /// In pt, this message translates to:
  /// **'Enviar'**
  String get btn_send;

  /// No description provided for @error_rag.
  ///
  /// In pt, this message translates to:
  /// **'Erro de conexão com o cérebro RAG.'**
  String get error_rag;

  /// No description provided for @error_access_denied.
  ///
  /// In pt, this message translates to:
  /// **'Acesso Negado. Credenciais inválidas.'**
  String get error_access_denied;

  /// No description provided for @error_session_expired.
  ///
  /// In pt, this message translates to:
  /// **'Sessão Expirada. Faça login novamente.'**
  String get error_session_expired;

  /// No description provided for @action_logout.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get action_logout;

  /// No description provided for @action_import_token.
  ///
  /// In pt, this message translates to:
  /// **'Importar via Token'**
  String get action_import_token;

  /// No description provided for @token_reading_label.
  ///
  /// In pt, this message translates to:
  /// **'Baixando Autos'**
  String get token_reading_label;

  /// No description provided for @token_success.
  ///
  /// In pt, this message translates to:
  /// **'Processo indexado. Você já pode fazer perguntas sobre estes autos.'**
  String get token_success;

  /// No description provided for @token_error.
  ///
  /// In pt, this message translates to:
  /// **'Erro na captura ou Token expirado.'**
  String get token_error;

  /// No description provided for @action_unlock_token.
  ///
  /// In pt, this message translates to:
  /// **'Desbloquear Token'**
  String get action_unlock_token;

  /// No description provided for @token_password_label.
  ///
  /// In pt, this message translates to:
  /// **'Senha do Certificado'**
  String get token_password_label;

  /// No description provided for @action_cancel.
  ///
  /// In pt, this message translates to:
  /// **'CANCELAR'**
  String get action_cancel;

  /// No description provided for @action_unlock.
  ///
  /// In pt, this message translates to:
  /// **'DESBLOQUEAR'**
  String get action_unlock;

  /// No description provided for @token_not_registered.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum token vinculado ao seu Gabinete.'**
  String get token_not_registered;

  /// No description provided for @action_link_token.
  ///
  /// In pt, this message translates to:
  /// **'Vincular Novo Certificado'**
  String get action_link_token;

  /// No description provided for @action_copy_saj.
  ///
  /// In pt, this message translates to:
  /// **'COPIAR PARA O SAJ'**
  String get action_copy_saj;

  /// No description provided for @label_minuta_editor.
  ///
  /// In pt, this message translates to:
  /// **'Minuta de Fundamentação'**
  String get label_minuta_editor;

  /// No description provided for @msg_copied.
  ///
  /// In pt, this message translates to:
  /// **'Copiado para a área de transferência!'**
  String get msg_copied;

  /// No description provided for @action_export_pdf.
  ///
  /// In pt, this message translates to:
  /// **'GERAR PDF PARA ASSINATURA'**
  String get action_export_pdf;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
