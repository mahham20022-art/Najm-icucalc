import 'package:markdown/markdown.dart' as md;

/// The `==highlighted text==` inline extension — not part of CommonMark
/// or GFM, but a widely-recognized convention (Obsidian, many other note
/// apps) for exactly what this feature's "Highlighting" requirement
/// asks for. Mirrors `markdown` package's own `StrikethroughSyntax`
/// (`~~text~~`) almost exactly, just with `=` instead of `~` and a
/// single `mark` tag rather than two.
///
/// Pure `dart:core` + `package:markdown` — no Flutter dependency — so
/// both the editor's live preview (`flutter_markdown_plus`, via
/// `HighlightElementBuilder`) and the data-layer PDF exporter (which
/// walks the same AST directly, no Flutter widgets involved) parse
/// `==...==` identically.
class HighlightSyntax extends md.DelimiterSyntax {
  HighlightSyntax()
    : super(
        r'==+',
        requiresDelimiterRun: true,
        allowIntraWord: false,
        tags: [md.DelimiterTag('mark', 2)],
      );
}
