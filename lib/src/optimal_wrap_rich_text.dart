import 'package:flutter/material.dart';

import 'optimal_wrap_rich_text_for_width.dart';

/// A widget that wraps rich text optimally.
final class OptimalWrapRichText extends StatelessWidget {
  /// Provide the width for edge cases where LayoutBuilder cannot be used.
  /// Such as inside SliverFillRemaining.
  final double? width;

  /// See equivalent property in [Text.rich].
  final InlineSpan text;

  /// See equivalent property in [Text.rich].
  final TextStyle? style;

  /// See equivalent property in [Text.rich].
  final StrutStyle? strutStyle;

  /// See equivalent property in [Text.rich].
  final TextAlign? textAlign;

  /// See equivalent property in [Text.rich].
  final TextDirection? textDirection;

  /// See equivalent property in [Text.rich].
  final Locale? locale;

  /// See equivalent property in [Text.rich].
  final bool? softWrap;

  /// See equivalent property in [Text.rich].
  final TextScaler? textScaler;

  /// See equivalent property in [Text.rich].
  final String? semanticsLabel;

  /// See equivalent property in [Text.rich].
  final TextWidthBasis? textWidthBasis;

  /// See equivalent property in [Text.rich].
  final TextHeightBehavior? textHeightBehavior;

  /// See equivalent property in [Text.rich].
  final Color? selectionColor;

  /// Creates a widget that wraps rich text optimally.
  const OptimalWrapRichText(
    this.text, {
    super.key,
    this.width,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.textScaler,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  });

  @override
  Widget build(BuildContext context) {
    if (width != null) {
      return OptimalWrapRichTextForWidth(
        text,
        width: width!,
        style: style,
        strutStyle: strutStyle,
        textAlign: textAlign,
        textDirection: textDirection,
        locale: locale,
        softWrap: softWrap,
        textScaler: textScaler,
        semanticsLabel: semanticsLabel,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
        selectionColor: selectionColor,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return OptimalWrapRichTextForWidth(
          text,
          width: constraints.maxWidth,
          style: style,
          strutStyle: strutStyle,
          textAlign: textAlign,
          textDirection: textDirection,
          locale: locale,
          softWrap: softWrap,
          textScaler: textScaler,
          semanticsLabel: semanticsLabel,
          textWidthBasis: textWidthBasis,
          textHeightBehavior: textHeightBehavior,
          selectionColor: selectionColor,
        );
      },
    );
  }
}
