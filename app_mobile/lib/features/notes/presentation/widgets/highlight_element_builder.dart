import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

/// Renders a `HighlightSyntax`-produced `<mark>` element as a
/// yellow-background inline span, the conventional look for Markdown
/// highlighting in the apps (Obsidian, Notion) this syntax borrows from.
class HighlightElementBuilder extends MarkdownElementBuilder {
  // The light-mode yellow read acceptably against forced black text, but
  // that same hardcoded black was previously used unconditionally — on a
  // dark-theme screen it produced a bright, unmuted yellow patch with no
  // accommodation for the surrounding dark palette. Both colors now
  // switch with brightness so the highlight reads as an accent rather
  // than a jarring cutout.
  static const _lightBackground = Color(0xFFFFF176);
  static const _darkBackground = Color(0xFF6B5B00);

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? _darkBackground : _lightBackground,
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Text(
        element.textContent,
        style: parentStyle?.copyWith(color: isDark ? Colors.white : Colors.black),
      ),
    );
  }
}
