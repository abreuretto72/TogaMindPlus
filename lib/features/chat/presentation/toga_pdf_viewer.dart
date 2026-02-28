import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:toga_mind_plus/core/toga_colors.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';

class TogaPdfView extends StatefulWidget {
  const TogaPdfView({super.key});

  @override
  State<TogaPdfView> createState() => _TogaPdfViewState();
}

class _TogaPdfViewState extends State<TogaPdfView> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  String? _pdfPath;
  int? _targetPage;
  String? _pdfConteudoIA;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _pdfPath = args['path'];
        _targetPage = args['page'];
        _pdfConteudoIA = args['conteudo'];
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
              child: _pdfConteudoIA != null 
                ? _buildPdfPreviewer() 
                : _buildNetworkViewer(),
            ),
            _buildTogaFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfPreviewer() {
    return PdfPreview(
      maxPageWidth: 700,
      build: (format) => _generatePdf(format, _pdfConteudoIA!),
      canDebug: false,
      loadingWidget: const CircularProgressIndicator(color: Color(0xFFFF9800)),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format, String text) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 10),
            child: pw.Text(
              'Página ${context.pageNumber} | © 2026 ScanNut Multiverso Digital',
              style: const pw.TextStyle(fontSize: 10),
            ),
          );
        },
        build: (pw.Context context) => [
          pw.Header(level: 0, child: pw.Text("Relatório Analítico TogaMind+")),
          ..._parseMarkdownToPdf(text),
        ],
      ),
    );

    return pdf.save();
  }

  List<pw.Widget> _parseMarkdownToPdf(String text) {
    if (text.isEmpty) return [];
    
    // Fallback pra quebrar por linhas evitando crash de paragrafos infinitos
    final lines = text.split('\n');
    final widgets = <pw.Widget>[];

    for (var line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(pw.SizedBox(height: 8));
        continue;
      }

      // Headers Markdown
      if (line.startsWith('### ')) {
        widgets.add(pw.SizedBox(height: 4));
        widgets.add(pw.Text(line.substring(4), style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)));
        widgets.add(pw.SizedBox(height: 2));
      } else if (line.startsWith('## ')) {
        widgets.add(pw.SizedBox(height: 8));
        widgets.add(pw.Text(line.substring(3), style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF005B70))));
        widgets.add(pw.SizedBox(height: 4));
      } else if (line.startsWith('# ')) {
        widgets.add(pw.SizedBox(height: 10));
        widgets.add(pw.Text(line.substring(2), style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF005B70))));
        widgets.add(pw.SizedBox(height: 6));
      } else {
        // Parágrafo Normal / Negrito Embutido
        final spans = <pw.TextSpan>[];
        final parts = line.split('**');
        
        for (int i = 0; i < parts.length; i++) {
          if (parts[i].isEmpty) continue;
          
          if (i % 2 == 1 && parts.length > 1) {
            // Parte Ímpar após split = Negrito **bold**
            spans.add(pw.TextSpan(text: parts[i], style: pw.TextStyle(fontWeight: pw.FontWeight.bold)));
          } else {
            // Conversão de Bullets
            String normalText = parts[i];
            if (i == 0) {
              if (normalText.trim().startsWith('* ')) {
                normalText = '• ' + normalText.substring(normalText.indexOf('*') + 1).trimLeft();
              } else if (normalText.trim().startsWith('- ')) {
                normalText = '• ' + normalText.substring(normalText.indexOf('-') + 1).trimLeft();
              }
            }
            spans.add(pw.TextSpan(text: normalText));
          }
        }
        
        // Renderiza a linha rica e da espaçamento minimo proxima linha
        widgets.add(pw.RichText(text: pw.TextSpan(children: spans, style: const pw.TextStyle(fontSize: 12))));
        widgets.add(pw.SizedBox(height: 4));
      }
    }
    
    return widgets;
  }

  Widget _buildNetworkViewer() {
    if (_pdfPath == null) {
      return const Center(child: Text('Erro ao carregar PDF.', style: TextStyle(color: Colors.white)));
    }
    return SfPdfViewer.network(
      _pdfPath!.startsWith('E:') 
        ? 'http://127.0.0.1:8000/process_pdf?path=${Uri.encodeComponent(_pdfPath!)}' // Proxy route
        : _pdfPath!,
      controller: _pdfViewerController,
      onDocumentLoaded: _onDocumentLoaded,
      canShowScrollHead: false,
      enableDoubleTapZooming: true,
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
