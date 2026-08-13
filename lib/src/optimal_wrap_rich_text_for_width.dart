// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'optimal_wrap_child.dart';
import 'utils/find_optimal_text_painter_width.dart';
import 'utils/inline_span_has_placeholders.dart';
import 'utils/text_align_to_alignment.dart';

final class OptimalWrapRichTextForWidth extends StatelessWidget {
  final double width;
  final bool shrinkWrap;
  final InlineSpan text;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow overflow;
  final TextScaler? textScaler;
  final int? minLines;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;

  const OptimalWrapRichTextForWidth(
    this.text, {
    super.key,
    required this.width,
    this.shrinkWrap = false,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow = TextOverflow.clip,
    this.textScaler,
    this.minLines,
    this.maxLines,
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

    final richText = Text.rich(
      text,
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaler: textScaler,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );

    late final Widget child;
    if (inlineSpanHasPlaceholders(text)) {
      child = OptimalWrapChild(
        maxWidth: width,
        minLines: minLines,
        child: richText,
      );
    } else {
      final effectiveStyle = defaultStyle.style.merge(style);
      final effectiveText = TextSpan(style: effectiveStyle, children: [text]);

      final painter = TextPainter(
        text: effectiveText,
        textDirection: effectiveTextDirection,
        textAlign: effectiveTextAlign,
        maxLines: maxLines,
        ellipsis: overflow == TextOverflow.ellipsis ? '\u2026' : null,
        strutStyle: strutStyle,
        textScaler: textScaler ?? MediaQuery.textScalerOf(context),
        locale: locale,
        textWidthBasis: textWidthBasis ?? TextWidthBasis.parent,
        textHeightBehavior:
            textHeightBehavior ?? DefaultTextHeightBehavior.maybeOf(context),
      )..layout(maxWidth: width);

      final optimalWidth = findOptimalTextPainterWidth(
        painter,
        minLines: minLines,
      );
      painter.dispose();

      child = SizedBox(width: optimalWidth, child: richText);
    }

    if (shrinkWrap) {
      return child;
    }

    return Align(
      alignment: effectiveTextAlign.toAlignment(effectiveTextDirection),
      child: child,
    );
  }
}
