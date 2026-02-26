import 'dart:async';
import 'package:flutter/material.dart';
import 'package:toga_mind_plus/l10n/app_localizations.dart';
import 'package:toga_mind_plus/core/toga_colors.dart';
import 'package:toga_mind_plus/features/draft/services/toga_storage_service.dart';
import 'package:toga_mind_plus/features/analysis/services/toga_analysis_service.dart';
import 'package:toga_mind_plus/features/draft/presentation/toga_chat_widget.dart';

class TogaDraftView extends StatefulWidget {
  const TogaDraftView({super.key});

  @override
  State<TogaDraftView> createState() => _TogaDraftViewState();
}

class _TogaDraftViewState extends State<TogaDraftView> {
  final TextEditingController _draftController = TextEditingController();
  final TogaAnalysisService _analysisService = TogaAnalysisService();
  Timer? _autoSaveTimer;
  Timer? _ragSyncTimer;
  bool _isRagSynced = false;

  @override
  void initState() {
    super.initState();
    _loadInitialDraft();
    _draftController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _ragSyncTimer?.cancel();
    _draftController.removeListener(_onTextChanged);
    _draftController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialDraft() async {
    final savedDraft = await TogaStorageService.loadDraft();
    if (savedDraft != null && savedDraft.isNotEmpty) {
      _draftController.text = savedDraft;
    }
  }

  void _onTextChanged() {
    if (_isRagSynced) {
      setState(() {
        _isRagSynced = false;
      });
    }

    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 5), () {
      _saveDraft(showFeedback: false);
    });

    _ragSyncTimer?.cancel();
    _ragSyncTimer = Timer(const Duration(seconds: 30), () {
      _syncRag();
    });
  }

  Future<void> _syncRag() async {
    if (_draftController.text.isNotEmpty) {
      final success = await _analysisService.syncWithRAG(
        contentType: 'rascunho',
        title: 'Draft_${DateTime.now().millisecondsSinceEpoch}',
        content: _draftController.text,
      );
      if (success && mounted) {
        setState(() {
          _isRagSynced = true;
        });
      }
    }
  }

  Future<void> _saveDraft({bool showFeedback = true}) async {
    final success = await TogaStorageService.saveDraft(_draftController.text);
    
    // RAG Sync silently in the background
    if (success && _draftController.text.isNotEmpty) {
      _analysisService.syncWithRAG(
        contentType: 'rascunho',
        title: 'Draft_${DateTime.now().millisecondsSinceEpoch}',
        content: _draftController.text,
      );
    }
    
    if (showFeedback && mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? l10n.msg_success : l10n.msg_error),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.draft_title),
        backgroundColor: TogaColors.azulPetroleo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveDraft(showFeedback: true),
            tooltip: l10n.action_save,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView( 
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDraftHeader(l10n),
              const SizedBox(height: 20),
              _buildEditorField(l10n),
              const SizedBox(height: 100), 
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: TogaColors.azulPetroleo,
        foregroundColor: Colors.white,
        child: const Icon(Icons.psychology),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const TogaChatWidget(),
          );
        },
      ),
      bottomSheet: _buildTogaStatusFooter(l10n),
    );
  }

  Widget _buildDraftHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Gelo Metálico
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          left: BorderSide(color: Color(0xFFFC2D7C), width: 4), // Destaque Magenta
        ),
      ),
      child: Text(
        l10n.draft_process_label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildEditorField(AppLocalizations l10n) {
    return TextField(
      controller: _draftController,
      maxLines: null, 
      keyboardType: TextInputType.multiline,
      style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black),
      decoration: InputDecoration(
        hintText: l10n.draft_hint,
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.4)),
      ),
    );
  }

  Widget _buildTogaStatusFooter(AppLocalizations l10n) {
    return Container(
      height: 40,
      width: double.infinity,
      color: const Color(0xFF1E1E1E),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.footer_copyright,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          if (_isRagSynced)
            Row(
              children: [
                const Icon(Icons.cloud_done, color: TogaColors.azulPetroleo, size: 16),
                const SizedBox(width: 4),
                Text(
                  l10n.msg_synced,
                  style: const TextStyle(color: TogaColors.azulPetroleo, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
