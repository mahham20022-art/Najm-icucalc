import 'dart:typed_data';

import 'package:markdown/markdown.dart' as md;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../markdown/highlight_syntax.dart' show HighlightSyntax;
import '../../domain/entities/note.dart';
import '../../domain/entities/note_image.dart';
import '../datasources/note_image_file_datasource.dart';

/// Renders a [Note]'s Markdown body to a PDF document.
///
/// A deliberately pragmatic subset of Markdown, not a full renderer:
/// headings, paragraphs (bold/italic/highlight/code inline spans),
/// bullet/numbered lists, blockquotes, and a paragraph containing a
/// single image. Tables, nested lists, and inline links-as-hyperlinks
/// are flattened to their plain text rather than richly rendered —
/// reasonable for a note-taking feature's "Export PDF" button, not for
/// a general-purpose Markdown-to-PDF service.
///
/// Only images with a *local* file on this device are embedded — an
/// image that only has a `remoteUrl` (synced in from another device,
/// never fetched here) is skipped with a small "image not available
/// offline" placeholder line, rather than this exporter reaching out to
/// the network itself.
class NotePdfExporter {
  NotePdfExporter(this._imageFiles);
  final NoteImageFileDataSource _imageFiles;

  Future<Uint8List> export(Note note) async {
    final imagesById = {for (final image in note.images) image.id: image};
    final document = md.Document(inlineSyntaxes: [HighlightSyntax()]);
    final nodes = document.parse(note.bodyMarkdown);

    final blocks = <pw.Widget>[];
    for (final node in nodes) {
      final widget = await _buildBlock(node, imagesById);
      if (widget != null) blocks.add(widget);
    }

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            note.title.trim().isEmpty ? 'Untitled Note' : note.title,
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 16),
          ...blocks,
        ],
      ),
    );
    return pdf.save();
  }

  Future<pw.Widget?> _buildBlock(md.Node node, Map<String, NoteImage> imagesById) async {
    if (node is md.Text) {
      final text = node.text.trim();
      return text.isEmpty
          ? null
          : pw.Padding(padding: const pw.EdgeInsets.only(bottom: 8), child: pw.Text(text));
    }
    if (node is! md.Element) return null;

    switch (node.tag) {
      case 'h1':
      case 'h2':
      case 'h3':
      case 'h4':
      case 'h5':
      case 'h6':
        const sizes = {'h1': 20.0, 'h2': 18.0, 'h3': 16.0, 'h4': 15.0, 'h5': 14.0, 'h6': 13.0};
        return pw.Padding(
          padding: const pw.EdgeInsets.only(top: 8, bottom: 6),
          child: pw.Text(
            node.textContent,
            style: pw.TextStyle(fontSize: sizes[node.tag], fontWeight: pw.FontWeight.bold),
          ),
        );

      case 'p':
        final children = node.children ?? const [];
        if (children.length == 1 &&
            children.first is md.Element &&
            (children.first as md.Element).tag == 'img') {
          final imageWidget = await _buildImage(children.first as md.Element, imagesById);
          return pw.Padding(padding: const pw.EdgeInsets.only(bottom: 12), child: imageWidget);
        }
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 8),
          child: pw.RichText(text: pw.TextSpan(children: _inlineSpans(children))),
        );

      case 'ul':
      case 'ol':
        final items = (node.children ?? const []).whereType<md.Element>().where(
          (child) => child.tag == 'li',
        );
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            for (final item in items)
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4, left: 12),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('•  '),
                    pw.Expanded(
                      child: pw.RichText(
                        text: pw.TextSpan(children: _inlineSpans(item.children ?? const [])),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );

      case 'blockquote':
        return pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 8),
          padding: const pw.EdgeInsets.only(left: 12),
          decoration: const pw.BoxDecoration(
            border: pw.Border(left: pw.BorderSide(width: 2, color: PdfColors.grey500)),
          ),
          child: pw.Text(node.textContent, style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
        );

      default:
        final text = node.textContent.trim();
        return text.isEmpty
            ? null
            : pw.Padding(padding: const pw.EdgeInsets.only(bottom: 8), child: pw.Text(text));
    }
  }

  Future<pw.Widget> _buildImage(md.Element imgElement, Map<String, NoteImage> imagesById) async {
    final src = imgElement.attributes['src'] ?? '';
    final uri = Uri.tryParse(src);
    final image = uri != null && uri.scheme == 'med100-image' ? imagesById[uri.path] : null;
    final localPath = image?.localPath;
    final bytes = localPath == null ? null : await _imageFiles.readBytes(localPath);
    if (bytes == null) {
      return pw.Text(
        '[image not available offline]',
        style: pw.TextStyle(fontStyle: pw.FontStyle.italic, color: PdfColors.grey600),
      );
    }
    return pw.Image(pw.MemoryImage(bytes), fit: pw.BoxFit.contain);
  }

  List<pw.InlineSpan> _inlineSpans(
    List<md.Node> nodes, {
    bool bold = false,
    bool italic = false,
    bool highlight = false,
  }) {
    final spans = <pw.InlineSpan>[];
    for (final node in nodes) {
      if (node is md.Text) {
        spans.add(
          pw.TextSpan(
            text: node.text,
            style: pw.TextStyle(
              fontWeight: bold ? pw.FontWeight.bold : null,
              fontStyle: italic ? pw.FontStyle.italic : null,
              background: highlight ? const pw.BoxDecoration(color: PdfColors.yellow200) : null,
            ),
          ),
        );
      } else if (node is md.Element) {
        switch (node.tag) {
          case 'strong':
            spans.addAll(
              _inlineSpans(
                node.children ?? const [],
                bold: true,
                italic: italic,
                highlight: highlight,
              ),
            );
          case 'em':
            spans.addAll(
              _inlineSpans(
                node.children ?? const [],
                bold: bold,
                italic: true,
                highlight: highlight,
              ),
            );
          case 'mark':
            spans.addAll(
              _inlineSpans(node.children ?? const [], bold: bold, italic: italic, highlight: true),
            );
          default:
            spans.addAll(
              _inlineSpans(
                node.children ?? const [],
                bold: bold,
                italic: italic,
                highlight: highlight,
              ),
            );
        }
      }
    }
    return spans;
  }
}
