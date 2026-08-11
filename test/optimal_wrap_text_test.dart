import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optimal_wrap_text/optimal_wrap_text.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final fontData = File('test/assets/roboto-regular.ttf').readAsBytesSync();
    final fontLoader = FontLoader('Roboto')
      ..addFont(Future.value(fontData.buffer.asByteData()));
    await fontLoader.load();
  });

  const text = 'My slightly longer text that will span 2 or 3 lines';
  const surfaceSize = Size(200, 300);

  testWidgets('Left', (tester) async {
    await tester.binding.setSurfaceSize(surfaceSize);

    await tester.pumpWidget(
      Wrapper(
        text: text,
        style: TextStyle(color: Colors.blue),
        textAlign: TextAlign.left,
      ),
    );

    await expectLater(
      find.byType(Wrapper),
      matchesGoldenFile('goldens/comparison_left.png'),
    );
  });

  testWidgets('Left', (tester) async {
    await tester.binding.setSurfaceSize(surfaceSize);

    await tester.pumpWidget(
      Wrapper(
        text: text,
        style: TextStyle(color: Colors.blue),
        textAlign: TextAlign.right,
      ),
    );

    await expectLater(
      find.byType(Wrapper),
      matchesGoldenFile('goldens/comparison_right.png'),
    );
  });

  testWidgets('Center', (tester) async {
    await tester.binding.setSurfaceSize(surfaceSize);

    await tester.pumpWidget(
      Wrapper(
        text: text,
        style: TextStyle(color: Colors.blue),
        textAlign: TextAlign.center,
      ),
    );

    await expectLater(
      find.byType(Wrapper),
      matchesGoldenFile('goldens/comparison_center.png'),
    );
  });

  testWidgets('Start RTL', (tester) async {
    await tester.binding.setSurfaceSize(surfaceSize);

    await tester.pumpWidget(
      Wrapper(
        text: text,
        style: TextStyle(color: Colors.blue),
        textAlign: TextAlign.start,
        textDirection: TextDirection.rtl,
      ),
    );

    await expectLater(
      find.byType(Wrapper),
      matchesGoldenFile('goldens/comparison_start_rtl.png'),
    );
  });

  testWidgets('End RTL', (tester) async {
    await tester.binding.setSurfaceSize(surfaceSize);

    await tester.pumpWidget(
      Wrapper(
        text: text,
        style: TextStyle(color: Colors.blue),
        textAlign: TextAlign.end,
        textDirection: TextDirection.rtl,
      ),
    );

    await expectLater(
      find.byType(Wrapper),
      matchesGoldenFile('goldens/comparison_end_rtl.png'),
    );
  });

  testWidgets('Rich text', (tester) async {
    await tester.binding.setSurfaceSize(surfaceSize);

    const richText = TextSpan(
      children: [
        TextSpan(text: 'My slightly '),
        TextSpan(text: 'longer', style: TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(text: ' rich text that will span 2 or 3 lines'),
      ],
    );

    await tester.pumpWidget(
      RichWrapper(
        text: richText,
        style: TextStyle(color: Colors.blue),
        textAlign: TextAlign.center,
      ),
    );

    final richTextFinder = find.descendant(
      of: find.byType(OptimalWrapRichText),
      matching: find.byType(RichText),
    );
    final richTextWidget = tester.widgetList<RichText>(richTextFinder).first;
    final sizedBox = tester
        .widgetList<SizedBox>(
          find.descendant(
            of: find.byType(OptimalWrapRichText),
            matching: find.byType(SizedBox),
          ),
        )
        .singleWhere((sizedBox) => sizedBox.width != null);

    expect(sizedBox.width, lessThan(surfaceSize.width));
    expect(
      richTextWidget.text.toPlainText(),
      'My slightly longer rich text that will span 2 or 3 lines',
    );

    await expectLater(
      find.byType(RichWrapper),
      matchesGoldenFile('goldens/comparison_rich_text.png'),
    );
  });

  testWidgets('Rich text with WidgetSpan', (tester) async {
    await tester.binding.setSurfaceSize(surfaceSize);

    final richText = TextSpan(
      children: [
        const TextSpan(text: 'My slightly '),
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: SizedBox(
            width: 12,
            height: 12,
            child: ColoredBox(color: Colors.red),
          ),
        ),
        const TextSpan(text: ' longer rich text that will span 2 or 3 lines'),
      ],
    );

    await tester.pumpWidget(
      RichWrapper(
        text: richText,
        style: TextStyle(color: Colors.blue),
        textAlign: TextAlign.center,
      ),
    );

    final wrapChild = tester.renderObject<RenderOptimalWrapChild>(
      find.byType(OptimalWrapChild),
    );
    expect(wrapChild.size.width, lessThan(surfaceSize.width));

    final plainHeight = tester.getSize(find.byType(RichText).first).height;
    final optimalHeight = tester
        .getSize(
          find.descendant(
            of: find.byType(OptimalWrapRichText),
            matching: find.byType(RichText),
          ),
        )
        .height;
    expect(optimalHeight, plainHeight);

    await expectLater(
      find.byType(RichWrapper),
      matchesGoldenFile('goldens/comparison_rich_text_widget_span.png'),
    );
  });

  testWidgets('Rich text with multiple WidgetSpans', (tester) async {
    await tester.binding.setSurfaceSize(surfaceSize);

    final richText = TextSpan(
      children: [
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: SizedBox(
            width: 10,
            height: 10,
            child: ColoredBox(color: Colors.green),
          ),
        ),
        const TextSpan(text: ' My slightly '),
        const TextSpan(
          text: 'longer',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const TextSpan(text: ' rich text '),
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: SizedBox(
            width: 10,
            height: 10,
            child: ColoredBox(color: Colors.orange),
          ),
        ),
        const TextSpan(text: ' that will span 2 or 3 lines'),
      ],
    );

    await tester.pumpWidget(
      RichWrapper(
        text: richText,
        style: TextStyle(color: Colors.blue),
        textAlign: TextAlign.center,
      ),
    );

    expect(find.byType(OptimalWrapChild), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is ColoredBox &&
            (widget.color == Colors.green || widget.color == Colors.orange),
      ),
      findsNWidgets(4),
    );

    final wrapChild = tester.renderObject<RenderOptimalWrapChild>(
      find.byType(OptimalWrapChild),
    );
    expect(wrapChild.size.width, lessThan(surfaceSize.width));

    await expectLater(
      find.byType(RichWrapper),
      matchesGoldenFile('goldens/comparison_rich_text_multiple_widget_spans.png'),
    );
  });

  testWidgets('maxLines fits and still narrows', (tester) async {
    await tester.binding.setSurfaceSize(surfaceSize);

    const longText =
        'My slightly longer text that will span 2 or 3 lines when wrapped';

    await tester.pumpWidget(
      Wrapper(
        text: longText,
        style: TextStyle(color: Colors.blue),
        textAlign: TextAlign.left,
        maxLines: 3,
      ),
    );

    final text = tester.widget<Text>(
      find.descendant(
        of: find.byType(OptimalWrapText),
        matching: find.byType(Text),
      ),
    );
    expect(text.maxLines, 3);

    final sizedBox = tester
        .widgetList<SizedBox>(
          find.descendant(
            of: find.byType(OptimalWrapText),
            matching: find.byType(SizedBox),
          ),
        )
        .singleWhere((box) => box.width != null);
    expect(sizedBox.width, lessThan(surfaceSize.width - 32));

    await expectLater(
      find.byType(Wrapper),
      matchesGoldenFile('goldens/comparison_max_lines_fit.png'),
    );
  });

  testWidgets('maxLines 2 truncates text that needs 3 lines', (tester) async {
    await tester.binding.setSurfaceSize(surfaceSize);

    final availableWidth = surfaceSize.width - 32;
    final unconstrained = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontFamily: 'Roboto', fontSize: 16, color: Colors.blue),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: availableWidth);
    expect(unconstrained.computeLineMetrics().length, 3);
    final unconstrainedHeight = unconstrained.height;
    unconstrained.dispose();

    await tester.pumpWidget(
      Wrapper(
        text: text,
        style: TextStyle(color: Colors.blue),
        textAlign: TextAlign.left,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );

    final innerText = tester.widget<Text>(
      find.descendant(
        of: find.byType(OptimalWrapText),
        matching: find.byType(Text),
      ),
    );
    expect(innerText.maxLines, 2);
    expect(innerText.overflow, TextOverflow.ellipsis);

    final sizedBox = tester
        .widgetList<SizedBox>(
          find.descendant(
            of: find.byType(OptimalWrapText),
            matching: find.byType(SizedBox),
          ),
        )
        .singleWhere((box) => box.width != null);
    expect(sizedBox.width, availableWidth);

    final optimalHeight = tester
        .getSize(
          find.descendant(
            of: find.byType(OptimalWrapText),
            matching: find.byType(RichText),
          ),
        )
        .height;
    expect(optimalHeight, lessThan(unconstrainedHeight));

    await expectLater(
      find.byType(Wrapper),
      matchesGoldenFile('goldens/comparison_max_lines_2_of_3.png'),
    );
  });

  testWidgets('maxLines that exceed at full width keep available width', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(surfaceSize);

    const longText =
        'This is a deliberately long sentence that cannot fit on a single '
        'line at the available width no matter how it is wrapped optimally';

    await tester.pumpWidget(
      Wrapper(
        text: longText,
        style: TextStyle(color: Colors.blue),
        textAlign: TextAlign.left,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );

    final text = tester.widget<Text>(
      find.descendant(
        of: find.byType(OptimalWrapText),
        matching: find.byType(Text),
      ),
    );
    expect(text.maxLines, 1);
    expect(text.overflow, TextOverflow.ellipsis);

    final sizedBox = tester
        .widgetList<SizedBox>(
          find.descendant(
            of: find.byType(OptimalWrapText),
            matching: find.byType(SizedBox),
          ),
        )
        .singleWhere((box) => box.width != null);
    expect(sizedBox.width, surfaceSize.width - 32);

    await expectLater(
      find.byType(Wrapper),
      matchesGoldenFile('goldens/comparison_max_lines_ellipsis.png'),
    );
  });

  testWidgets('overflow ellipsis is forwarded', (tester) async {
    await tester.binding.setSurfaceSize(surfaceSize);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DefaultTextHeightBehavior(
          textHeightBehavior: TextHeightBehavior(),
          child: DefaultTextStyle(
            style: TextStyle(fontFamily: 'Roboto', fontSize: 16),
            child: Center(
              child: SizedBox(
                width: surfaceSize.width,
                child: OptimalWrapText(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final innerText = tester.widget<Text>(
      find.descendant(
        of: find.byType(OptimalWrapText),
        matching: find.byType(Text),
      ),
    );
    expect(innerText.maxLines, 1);
    expect(innerText.overflow, TextOverflow.ellipsis);
  });

  testWidgets('rich maxLines 2 truncates text that needs 3 lines', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(surfaceSize);

    const richText = TextSpan(
      children: [
        TextSpan(text: 'My slightly '),
        TextSpan(text: 'longer', style: TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(text: ' text that will span 2 or 3 lines'),
      ],
    );

    final availableWidth = surfaceSize.width - 32;
    final unconstrained = TextPainter(
      text: TextSpan(
        style: TextStyle(fontFamily: 'Roboto', fontSize: 16, color: Colors.blue),
        children: [richText],
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: availableWidth);
    expect(unconstrained.computeLineMetrics().length, 3);
    final unconstrainedHeight = unconstrained.height;
    unconstrained.dispose();

    await tester.pumpWidget(
      RichWrapper(
        text: richText,
        style: TextStyle(color: Colors.blue),
        textAlign: TextAlign.left,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );

    final richTextWidget = tester
        .widgetList<RichText>(
          find.descendant(
            of: find.byType(OptimalWrapRichText),
            matching: find.byType(RichText),
          ),
        )
        .first;
    expect(richTextWidget.maxLines, 2);
    expect(richTextWidget.overflow, TextOverflow.ellipsis);

    final sizedBox = tester
        .widgetList<SizedBox>(
          find.descendant(
            of: find.byType(OptimalWrapRichText),
            matching: find.byType(SizedBox),
          ),
        )
        .singleWhere((box) => box.width != null);
    expect(sizedBox.width, availableWidth);

    final optimalHeight = tester
        .getSize(
          find.descendant(
            of: find.byType(OptimalWrapRichText),
            matching: find.byType(RichText),
          ),
        )
        .height;
    expect(optimalHeight, lessThan(unconstrainedHeight));

    await expectLater(
      find.byType(RichWrapper),
      matchesGoldenFile('goldens/comparison_rich_max_lines_2_of_3.png'),
    );
  });

  testWidgets('rich maxLines that exceed at full width keep available width', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(surfaceSize);

    const richText = TextSpan(
      text:
          'This is a deliberately long sentence that cannot fit on a single '
          'line at the available width no matter how it is wrapped optimally',
    );

    await tester.pumpWidget(
      RichWrapper(
        text: richText,
        style: TextStyle(color: Colors.blue),
        textAlign: TextAlign.left,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );

    final richTextWidget = tester
        .widgetList<RichText>(
          find.descendant(
            of: find.byType(OptimalWrapRichText),
            matching: find.byType(RichText),
          ),
        )
        .first;
    expect(richTextWidget.maxLines, 1);
    expect(richTextWidget.overflow, TextOverflow.ellipsis);

    final sizedBox = tester
        .widgetList<SizedBox>(
          find.descendant(
            of: find.byType(OptimalWrapRichText),
            matching: find.byType(SizedBox),
          ),
        )
        .singleWhere((box) => box.width != null);
    expect(sizedBox.width, surfaceSize.width - 32);

    await expectLater(
      find.byType(RichWrapper),
      matchesGoldenFile('goldens/comparison_rich_max_lines_ellipsis.png'),
    );
  });

  testWidgets('OptimalWrapText shrinkWrap sizes to optimal width', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(surfaceSize);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DefaultTextStyle(
          style: const TextStyle(fontFamily: 'Roboto', fontSize: 16),
          child: Center(
            child: OptimalWrapText(
              text,
              width: surfaceSize.width,
              shrinkWrap: true,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    final shrinkSize = tester.getSize(find.byType(OptimalWrapText));
    expect(shrinkSize.width, lessThan(surfaceSize.width));
    expect(
      find.descendant(
        of: find.byType(OptimalWrapText),
        matching: find.byType(Align),
      ),
      findsNothing,
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DefaultTextStyle(
          style: const TextStyle(fontFamily: 'Roboto', fontSize: 16),
          child: Center(
            child: OptimalWrapText(
              text,
              width: surfaceSize.width,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    final expandedSize = tester.getSize(find.byType(OptimalWrapText));
    expect(expandedSize.width, surfaceSize.width);
    expect(
      find.descendant(
        of: find.byType(OptimalWrapText),
        matching: find.byType(Align),
      ),
      findsOneWidget,
    );
  });

  testWidgets('OptimalWrapRichText shrinkWrap sizes to optimal width', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(surfaceSize);

    const richText = TextSpan(
      children: [
        TextSpan(text: 'My slightly '),
        TextSpan(
          text: 'longer',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(text: ' rich text that will span 2 or 3 lines'),
      ],
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DefaultTextStyle(
          style: const TextStyle(fontFamily: 'Roboto', fontSize: 16),
          child: Center(
            child: OptimalWrapRichText(
              richText,
              width: surfaceSize.width,
              shrinkWrap: true,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(OptimalWrapRichText)).width,
      lessThan(surfaceSize.width),
    );
    expect(
      find.descendant(
        of: find.byType(OptimalWrapRichText),
        matching: find.byType(Align),
      ),
      findsNothing,
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DefaultTextStyle(
          style: const TextStyle(fontFamily: 'Roboto', fontSize: 16),
          child: Center(
            child: OptimalWrapRichText(
              richText,
              width: surfaceSize.width,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(OptimalWrapRichText)).width,
      surfaceSize.width,
    );
    expect(
      find.descendant(
        of: find.byType(OptimalWrapRichText),
        matching: find.byType(Align),
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'OptimalWrapRichText shrinkWrap with WidgetSpan sizes to optimal width',
    (tester) async {
      await tester.binding.setSurfaceSize(surfaceSize);

      final richText = TextSpan(
        children: [
          const TextSpan(text: 'My slightly '),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: SizedBox(
              width: 12,
              height: 12,
              child: ColoredBox(color: Colors.red),
            ),
          ),
          const TextSpan(
            text: ' longer rich text that will span 2 or 3 lines',
          ),
        ],
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DefaultTextStyle(
            style: const TextStyle(fontFamily: 'Roboto', fontSize: 16),
            child: Center(
              child: OptimalWrapRichText(
                richText,
                width: surfaceSize.width,
                shrinkWrap: true,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(OptimalWrapChild), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(OptimalWrapRichText),
          matching: find.byType(Align),
        ),
        findsNothing,
      );
      expect(
        tester.getSize(find.byType(OptimalWrapRichText)).width,
        lessThan(surfaceSize.width),
      );
    },
  );

  testWidgets(
    'OptimalWrapText shrinkWrap via LayoutBuilder under loose constraints',
    (tester) async {
      await tester.binding.setSurfaceSize(surfaceSize);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DefaultTextStyle(
            style: const TextStyle(fontFamily: 'Roboto', fontSize: 16),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: surfaceSize.width),
                child: OptimalWrapText(
                  text,
                  shrinkWrap: true,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      );

      expect(
        tester.getSize(find.byType(OptimalWrapText)).width,
        lessThan(surfaceSize.width),
      );
    },
  );

  test('findOptimalTextPainterWidth narrows without changing height', () {
    final painter = TextPainter(
      text: const TextSpan(
        text: text,
        style: TextStyle(fontFamily: 'Roboto', fontSize: 16),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: surfaceSize.width);

    final fullHeight = painter.height;
    final fullWidth = painter.width;
    final optimalWidth = findOptimalTextPainterWidth(painter);

    expect(optimalWidth, lessThan(fullWidth));

    painter.layout(maxWidth: optimalWidth);
    expect(painter.height, fullHeight);
    painter.dispose();
  });
}

final class Wrapper extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final int? maxLines;
  final TextOverflow overflow;

  const Wrapper({
    super.key,
    required this.text,
    required this.style,
    required this.textAlign,
    this.textDirection = TextDirection.ltr,
    this.maxLines,
    this.overflow = TextOverflow.clip,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: textDirection,
      child: DefaultTextHeightBehavior(
        textHeightBehavior: TextHeightBehavior(),
        child: DefaultTextStyle(
          style: TextStyle(fontFamily: 'Roboto', fontSize: 16),
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.all(16),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: style,
                    textAlign: textAlign,
                    maxLines: maxLines,
                    overflow: overflow,
                  ),
                  SizedBox(height: 16),
                  OptimalWrapText(
                    text,
                    style: style,
                    textAlign: textAlign,
                    maxLines: maxLines,
                    overflow: overflow,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class RichWrapper extends StatelessWidget {
  final InlineSpan text;
  final TextStyle style;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow overflow;

  const RichWrapper({
    super.key,
    required this.text,
    required this.style,
    required this.textAlign,
    this.maxLines,
    this.overflow = TextOverflow.clip,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: DefaultTextHeightBehavior(
        textHeightBehavior: TextHeightBehavior(),
        child: DefaultTextStyle(
          style: TextStyle(fontFamily: 'Roboto', fontSize: 16),
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.all(16),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    text,
                    style: style,
                    textAlign: textAlign,
                    maxLines: maxLines,
                    overflow: overflow,
                  ),
                  SizedBox(height: 16),
                  OptimalWrapRichText(
                    text,
                    style: style,
                    textAlign: textAlign,
                    maxLines: maxLines,
                    overflow: overflow,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
