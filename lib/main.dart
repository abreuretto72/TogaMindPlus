import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:toga_mind_plus/l10n/app_localizations.dart';
import 'package:toga_mind_plus/features/dashboard/presentation/toga_main_view.dart';
import 'package:toga_mind_plus/features/auth/presentation/toga_login_view.dart';
import 'package:toga_mind_plus/features/auth/presentation/toga_register_view.dart';
import 'package:toga_mind_plus/features/chat/presentation/toga_contextual_chat_view.dart';
import 'package:toga_mind_plus/features/chat/presentation/toga_pdf_viewer.dart';
import 'package:toga_mind_plus/core/toga_colors.dart';

void main() {
  runApp(const TogaMindApp());
}

class TogaMindApp extends StatelessWidget {
  const TogaMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.app_title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: TogaColors.azulPetroleo),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt'), // Portuguese
      ],
      initialRoute: '/',
      routes: {
        '/': (context) => const TogaLoginView(),
        '/register': (context) => const TogaRegisterView(),
        '/home': (context) => const TogaMainView(),
        '/chat': (context) => const TogaContextualChatView(),
        '/pdf_viewer': (context) => const TogaPdfView(),
      },
    );
  }
}
