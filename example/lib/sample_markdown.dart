const sampleMarkdown = r'''# Markdown, as it arrives

Edit the source, or press **Stream** to replay this document in small chunks.
Select text in the preview, then copy the selection as Markdown.

## Text and code

Keep **bold**, *emphasis*, ~~strikethrough~~, and `inline code` in one document.
Unicode stays intact: 你好，世界 🌍.

```dart
SelectionArea(
  child: MarkstreamView(
    source: cumulativeMarkdown,
    streaming: isStreaming,
  ),
)
```

## Structured content

| Capability | Behavior |
| --- | --- |
| Streaming | Completed blocks retain their identity |
| Selection | Copies text with source-aware formatting |
| Extensions | Applications provide custom renderers |

- [x] Keep parsing and rendering separate
- [x] Let applications own selection menus
- [ ] Add the adapters your application needs

> [!TIP]
> Code highlighting, visual math, images, and link handling are injectable.

<details>
<summary>More about this example</summary>

The example depends only on the standalone package next to it.
Links show their destination in a notification inside the app.

</details>

[Flutter documentation](https://docs.flutter.dev/)
''';
