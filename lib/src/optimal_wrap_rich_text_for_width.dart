// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'utils/find_optimal_text_painter_width.dart';
import 'utils/text_align_to_alignment.dart';

final class OptimalWrapRichTextForWidth extends StatelessWidget {
  final double width;
  final InlineSpan text;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextScaler? textScaler;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;

  const OptimalWrapRichTextForWidth(
    this.text, {
    super.key,
    required this.width,
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
    final defaultStyle = DefaultTextStyle.of(context);
    final effectiveTextAlign =
        textAlign ?? defaultStyle.textAlign ?? TextAlign.start;
    final effectiveTextDirection = textDirection ?? Directionality.of(context);
    final effectiveStyle = defaultStyle.style.merge(style);
    final effectiveText = TextSpan(style: effectiveStyle, children: [text]);

    final painter = TextPainter(
      text: effectiveText,
      textDirection: effectiveTextDirection,
      textAlign: effectiveTextAlign,
      strutStyle: strutStyle,
      textScaler: textScaler ?? MediaQuery.textScalerOf(context),
      locale: locale,
      textWidthBasis: textWidthBasis ?? TextWidthBasis.parent,
      textHeightBehavior:
          textHeightBehavior ?? DefaultTextHeightBehavior.maybeOf(context),
    )..layout(maxWidth: width);

    final optimalWidth = findOptimalTextPainterWidth(painter);
    painter.dispose();

    return Align(
      alignment: effectiveTextAlign.toAlignment(effectiveTextDirection),
      child: SizedBox(
        width: optimalWidth,
        child: Text.rich(
          text,
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
        ),
      ),
    );
  }
}
