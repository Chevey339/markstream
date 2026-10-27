import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markstream/markstream.dart';
import 'package:markstream_example/main.dart';
import 'package:markstream_example/sample_markdown.dart';

void main() {
  testWidgets('editing source updates the standalone package preview', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MarkstreamExampleApp());
    await tester.pumpAndSettle();
    expect(find.byType(SelectionArea), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('markdown-source')),
      '# Edited\n\n**Hello** from a separate application.',
    );
    await tester.pumpAndSettle();
    final preview = tester.widget<MarkstreamView>(find.byType(MarkstreamView));
    expect(preview.source, contains('**Hello**'));
    expect(preview.streaming, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('narrow layout streams cumulative source and completes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MarkstreamExampleApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Stream'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    var preview = tester.widget<MarkstreamView>(find.byType(MarkstreamView));
    expect(preview.streaming, isTrue);
    expect(preview.source, isNotEmpty);
    expect(preview.source!.length, lessThan(sampleMarkdown.length));
    expect(sampleMarkdown.startsWith(preview.source!), isTrue);
    for (var i = 0; i < 200; i++) {
      await tester.pump(const Duration(milliseconds: 25));
    }
    await tester.pumpAndSettle();
    preview = tester.widget<MarkstreamView>(find.byType(MarkstreamView));
    expect(preview.source, sampleMarkdown);
    expect(preview.streaming, isFalse);
    expect(find.text('Ready'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
