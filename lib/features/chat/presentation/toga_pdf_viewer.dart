import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:toga_mind_plus/core/toga_colors.dart';

class TogaPdfView extends StatefulWidget {
  const TogaPdfView({super.key});

  @override
  State<TogaPdfView> createState() => _TogaPdfViewState();
}

class _TogaPdfViewState extends State<TogaPdfView> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  String? _pdfPath;
  int? _targetPage;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _pdfPath = args['path'];
        _targetPage = args['page'];
      }
      _isInit = true;
    }
  }

  void _onDocumentLoaded(PdfDocumentLoadedDetails details) {
    if (_targetPage != null && _targetPage! > 0) {
       _pdfViewerController.jumpToPage(_targetPage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Protocolo 2026: Black Box
      appBar: AppBar(
        title: Text('Evidência Documental (Pág. $_targetPage)'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              // Usar InteractiveViewer + PdfViewer para mobile
              child: _pdfPath == null 
                ? const Center(child: Text('Erro ao carregar PDF.', style: TextStyle(color: Colors.white)))
                : SfPdfViewer.network(
                    _pdfPath!.startsWith('E:') 
                      ? 'http://127.0.0.1:8000/process_pdf?path=${Uri.encodeComponent(_pdfPath!)}' // Proxy route since Flutter Web cant read absolute Drive E
                      : _pdfPath!,
                    controller: _pdfViewerController,
                    onDocumentLoaded: _onDocumentLoaded,
                    canShowScrollHead: false,
                    enableDoubleTapZooming: true,
                  ),
            ),
            _buildTogaFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildTogaFooter() {
    return Container(
      height: 40,
      width: double.infinity,
      color: Colors.black,
      alignment: Alignment.center,
      child: Text(
        'Protocolo 2026 | © 2026 ScanNut Multiverso Digital',
        style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10),
      ),
    );
  }
}
