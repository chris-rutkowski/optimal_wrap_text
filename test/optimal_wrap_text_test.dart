import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optimal_wrap_text/optimal_wrap_text.dart';
import 'package:optimal_wrap_text/src/optimal_wrap_child.dart';

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
}

final class Wrapper extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final TextDirection textDirection;

  const Wrapper({
    super.key,
    required this.text,
    required this.style,
    required this.textAlign,
    this.textDirection = TextDirection.ltr,
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
                  Text(text, style: style, textAlign: textAlign),
                  SizedBox(height: 16),
                  OptimalWrapText(text, style: style, textAlign: textAlign),
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

  const RichWrapper({
    super.key,
    required this.text,
    required this.style,
    required this.textAlign,
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
                  Text.rich(text, style: style, textAlign: textAlign),
                  SizedBox(height: 16),
                  OptimalWrapRichText(text, style: style, textAlign: textAlign),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
