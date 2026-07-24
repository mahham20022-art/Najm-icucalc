import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

/// Renders a `HighlightSyntax`-produced `<mark>` element as a
/// yellow-background inline span, the conventional look for Markdown
/// highlighting in the apps (Obsidian, Notion) this syntax borrows from.
class HighlightElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    return Container(
      color: const Color(0xFFFFF176),
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Text(element.textContent, style: parentStyle?.copyWith(color: Colors.black)),
    );
  }
}
