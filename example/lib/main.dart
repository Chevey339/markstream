import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:markstream/markstream.dart';

import 'sample_markdown.dart';

void main() => runApp(const MarkstreamExampleApp());

class MarkstreamExampleApp extends StatelessWidget {
  const MarkstreamExampleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Markstream playground',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: const Color(0xff28685c)),
    darkTheme: ThemeData(
      colorSchemeSeed: const Color(0xff28685c),
      brightness: Brightness.dark,
    ),
    home: const MarkdownPlayground(),
  );
}

class MarkdownPlayground extends StatefulWidget {
  const MarkdownPlayground({super.key});

  @override
  State<MarkdownPlayground> createState() => _MarkdownPlaygroundState();
}

class _MarkdownPlaygroundState extends State<MarkdownPlayground> {
  final _source = TextEditingController(text: sampleMarkdown);
  final _selection = MarkstreamSelectionController();
  String _visibleSource = sampleMarkdown;
  Timer? _timer;

  void _stream() {
    // Send cumulative snapshots, preserving complete Unicode code points.
    final characters = _source.text.runes.toList();
    var offset = 0;
    setState(() {
      _visibleSource = '';
      _timer = Timer.periodic(const Duration(milliseconds: 25), (timer) {
        setState(() {
          offset = math.min(offset + 8, characters.length);
          _visibleSource = String.fromCharCodes(characters.take(offset));
          if (offset == characters.length) {
            timer.cancel();
            _timer = null;
          }
        });
      });
    });
  }

  void _showAll() {
    _timer?.cancel();
    setState(() {
      _timer = null;
      _visibleSource = _source.text;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _source.dispose();
    _selection.dispose();
    super.dispose();
  }

  Widget _editor() => Padding(
    padding: const EdgeInsets.all(16),
    child: TextField(
      key: const ValueKey('markdown-source'),
      controller: _source,
      readOnly: _timer != null,
      expands: true,
      maxLines: null,
      minLines: null,
      textAlignVertical: TextAlignVertical.top,
      style: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 14,
        height: 1.6,
      ),
      decoration: const InputDecoration(
        labelText: 'Markdown source',
        alignLabelWithHint: true,
        border: OutlineInputBorder(),
      ),
      onChanged: (value) => setState(() => _visibleSource = value),
    ),
  );

  Widget _preview() => SelectionArea(
    child: SingleChildScrollView(
      key: const ValueKey('markdown-preview'),
      padding: const EdgeInsets.all(24),
      child: MarkstreamView(
        source: _visibleSource,
        streaming: _timer != null,
        selectionController: _selection,
        linkHandler: const PreviewLinkHandler(),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Markstream playground')),
    body: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilledButton(
                  onPressed: _timer != null
                      ? _showAll
                      : _source.text.isEmpty
                      ? null
                      : _stream,
                  child: Text(_timer != null ? 'Show all' : 'Stream'),
                ),
                ListenableBuilder(
                  listenable: _selection,
                  builder: (context, _) => OutlinedButton(
                    onPressed: _selection.hasSelection
                        ? _selection.copySelectionAsMarkdown
                        : null,
                    child: const Text('Copy selection as Markdown'),
                  ),
                ),
                Text(_timer == null ? 'Ready' : 'Streaming…'),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 900) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _editor()),
                      const VerticalDivider(width: 1),
                      Expanded(child: _preview()),
                    ],
                  );
                }
                return DefaultTabController(
                  length: 2,
                  initialIndex: 1,
                  child: Column(
                    children: [
                      const TabBar(
                        tabs: [
                          Tab(text: 'Source'),
                          Tab(text: 'Preview'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(children: [_editor(), _preview()]),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

/// Applications choose how links open. This demo shows the destination in-app.
class PreviewLinkHandler implements LinkHandler {
  const PreviewLinkHandler();

  @override
  void open(BuildContext context, LinkNode link) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(link.destination)));
  }
}
