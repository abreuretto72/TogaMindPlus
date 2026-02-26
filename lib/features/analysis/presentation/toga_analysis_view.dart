import 'package:flutter/material.dart';
import 'package:toga_mind_plus/l10n/app_localizations.dart';
import 'package:toga_mind_plus/core/toga_colors.dart';
import 'package:toga_mind_plus/features/analysis/services/toga_analysis_service.dart';

class TogaAnalysisView extends StatefulWidget {
  const TogaAnalysisView({super.key});

  @override
  State<TogaAnalysisView> createState() => _TogaAnalysisViewState();
}

class _TogaAnalysisViewState extends State<TogaAnalysisView> {
  final TogaAnalysisService _analysisService = TogaAnalysisService();
  bool _isLoading = false;
  String? _analysisResult;

  Future<void> _handleUpload(AppLocalizations l10n) async {
    final file = await _analysisService.pickProcessPdf();
    
    if (file != null && file.bytes != null) {
      setState(() {
        _isLoading = true;
        _analysisResult = null;
      });

      // Simulação do envio para o Gemini 3 Flash
      final result = await _analysisService.sendToAI(file.bytes!, file.name);

      setState(() {
        _isLoading = false;
        _analysisResult = result ?? l10n.error_pdf;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.analysis_title),
        backgroundColor: TogaColors.azulPetroleo,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView( 
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildUploadSection(l10n),
              const SizedBox(height: 30),
              if (_isLoading) _buildLoadingState(l10n),
              if (_analysisResult != null) _buildResultCard(l10n),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildTogaFooter(l10n),
    );
  }

  Widget _buildUploadSection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TogaColors.azulPetroleo.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.picture_as_pdf, size: 60, color: TogaColors.azulPetroleo),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : () => _handleUpload(l10n),
            icon: const Icon(Icons.upload_file),
            label: Text(l10n.btn_upload),
            style: ElevatedButton.styleFrom(
              backgroundColor: TogaColors.azulPetroleo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(AppLocalizations l10n) {
    return Column(
      children: [
        const CircularProgressIndicator(color: TogaColors.azulPetroleo),
        const SizedBox(height: 16),
        Text(l10n.msg_analyzing),
      ],
    );
  }

  Widget _buildResultCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          left: BorderSide(color: Color(0xFFFC2D7C), width: 5), // Borda Magenta
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.result_label,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFC2D7C)),
          ),
          const SizedBox(height: 12),
          Text(
            _analysisResult!,
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildTogaFooter(AppLocalizations l10n) {
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
