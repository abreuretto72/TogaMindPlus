import 'package:flutter/material.dart';
import 'package:toga_mind_plus/l10n/app_localizations.dart';

class TogaStatusBackupWidget extends StatelessWidget {
  final bool backupSucesso;
  final String ultimaData;

  const TogaStatusBackupWidget({
    super.key, 
    required this.backupSucesso, 
    required this.ultimaData
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: backupSucesso ? const Color(0xFF10AC84) : Colors.red, // Verde Sucesso / Vermelho Erro
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            backupSucesso ? l10n.statusSucesso : l10n.statusErro,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text(
            l10n.msgBackupLocal + ": " + ultimaData,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
