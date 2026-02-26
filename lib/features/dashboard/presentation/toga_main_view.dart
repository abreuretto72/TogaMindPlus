import 'package:flutter/material.dart';
import 'package:toga_mind_plus/l10n/app_localizations.dart';
import 'package:toga_mind_plus/core/toga_colors.dart';
import 'package:toga_mind_plus/features/draft/presentation/toga_draft_view.dart';
import 'package:toga_mind_plus/features/analysis/presentation/toga_analysis_view.dart';
import 'package:toga_mind_plus/features/import/presentation/toga_token_import_view.dart';
import 'package:toga_mind_plus/core/models/toga_config_model.dart';
import 'package:toga_mind_plus/core/services/toga_config_service.dart';
import 'package:toga_mind_plus/core/services/toga_auth_service.dart';

class TogaMainView extends StatefulWidget {
  const TogaMainView({super.key});

  @override
  State<TogaMainView> createState() => _TogaMainViewState();
}

class _TogaMainViewState extends State<TogaMainView> {
  late Future<TogaConfigModel> _configFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Start fetching config safely with l10n context
    _configFuture = TogaConfigService.fetchConfig(l10n: AppLocalizations.of(context));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<TogaConfigModel>(
      future: _configFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: TogaColors.azulPetroleo,
            body: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        final config = snapshot.data ?? TogaConfigModel.fallback();

        if (config.maintenanceMode) {
          return Scaffold(
            backgroundColor: const Color(0xFFFF5252), // Vermelho de erro/manutenção
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.warning, size: 64, color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    config.systemMessage,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.app_title), 
            backgroundColor: TogaColors.azulPetroleo,
            foregroundColor: Colors.white,
            actions: [
              TextButton.icon(
                icon: const Icon(Icons.logout, color: Color(0xFFFC2D7C)),
                label: Text(l10n.action_logout, style: const TextStyle(color: Color(0xFFFC2D7C))),
                onPressed: () async {
                  await TogaAuthService.logout();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/');
                  }
                },
              )
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView( 
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, l10n),
                  if (config.systemMessage.isNotEmpty && config.systemMessage != 'Servidor Operacional (Fallback Local)' && config.systemMessage != 'Servidor TogaMind+ Operacional') 
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        config.systemMessage,
                        style: const TextStyle(color: TogaColors.azulPetroleo, fontStyle: FontStyle.italic),
                      ),
                    ),
                  const SizedBox(height: 24),
                  _buildActionCards(context, l10n),
                ],
              ),
            ),
          ),
          bottomNavigationBar: _buildTogaFooter(context, l10n),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.dashboard_welcome,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 8),
        const Divider(color: Color(0xFFFC2D7C), thickness: 2), // Magenta de Destaque
      ],
    );
  }

  Widget _buildActionCards(BuildContext context, AppLocalizations l10n) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildClickableIcon(
          icon: Icons.description,
          label: l10n.action_new_draft,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TogaDraftView()),
            );
          },
        ),
        _buildClickableIcon(
          icon: Icons.gavel,
          label: l10n.action_processes,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TogaAnalysisView()),
            );
          },
        ),
        _buildClickableIcon(
          icon: Icons.vpn_key_outlined,
          label: l10n.action_import_token,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TogaTokenImportView()),
            );
          },
        ),
        _buildClickableIcon(
          icon: Icons.delete_outline,
          label: l10n.action_delete,
          onPressed: () {},
          isDelete: true,
        ),
      ],
    );
  }

  Widget _buildClickableIcon({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isDelete = false,
  }) {
    final Color iconColor = isDelete ? const Color(0xFFFF5252) : TogaColors.azulPetroleo;
    
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 32),
          color: iconColor,
          onPressed: onPressed,
          tooltip: label,
        ),
        Text(label, style: TextStyle(color: iconColor, fontSize: 12)),
      ],
    );
  }

  Widget _buildTogaFooter(BuildContext context, AppLocalizations l10n) {
    return Container(
      height: 50,
      color: Colors.black,
      alignment: Alignment.center,
      child: Text(
        l10n.footer_copyright,
        style: const TextStyle(color: Colors.white70, fontSize: 10),
      ),
    );
  }
}
