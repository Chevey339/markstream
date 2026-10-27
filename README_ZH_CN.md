# markstream

**面向 Flutter AI 对话的流式 Markdown 库，支持丰富内容、原文坐标和跨内容选择。**

[![pub package](https://img.shields.io/pub/v/markstream.svg)](https://pub.dev/packages/markstream)
[![Package checks](https://github.com/Chevey339/markstream/actions/workflows/ci.yml/badge.svg)](https://github.com/Chevey339/markstream/actions/workflows/ci.yml)

[English](README.md) · [pub.dev](https://pub.dev/packages/markstream) ·
[使用指南](doc/guide.md) · [示例](example/README.md) ·
[GitHub](https://github.com/Chevey339/markstream)

适用于 AI 聊天、Markdown 预览、文档阅读和富文本助手回复。
Markstream 源自 [Kelivo](https://github.com/Chevey339/kelivo)，现作为独立 Flutter 库维护。
它把增量解析、Flutter 原生渲染、结构化选择复制和可扩展 AST 放在同一套实现中。

## 支持哪些内容？

| 类型 | 功能 |
| --- | --- |
| **富文本** | 标题、粗体、斜体、删除线、`==高亮==`、行内代码、转义、HTML 实体 |
| **列表与结构** | 有序/无序/嵌套列表、引用、分隔线、任务复选框、单选项 |
| **表格** | 列对齐、单元格内富文本、横向滚动、分页、TSV 选择、Markdown/CSV 复制和 PNG 截图回调 |
| **代码块** | 围栏语法、语言标签、复制、折叠、换行配置和大代码块分段渲染；可接入语法高亮 |
| **公式** | `$…$`、`\(…\)` 行内公式和 `$$…$$`、`\[…\]` 块公式语法；可接入 LaTeX 排版组件 |
| **链接与图片** | 普通链接、引用式链接、自动链接和图片语法；通过适配器接入跳转和图片显示 |
| **提示与扩展卡片** | GitHub NOTE/TIP/IMPORTANT/WARNING/CAUTION 提示、`:::note` 等容器和自定义指令 |
| **折叠内容** | `<details>` / `<summary>`，保留用户展开状态 |
| **HTML 子集** | 文本样式、链接、图片、列表、表格、对齐、上/下标以及有限的行内 CSS |
| **流式更新** | 传入累计全文、复用已完成内容、处理未闭合语法、可选乐观闭合以及长回复更新合并 |
| **选择与复制** | 跨段落、代码、表格和内联组件选择；纯文本/Markdown 复制及选区原文范围 |
| **原文高亮** | 按原文 UTF-16 范围绘制搜索命中、标注或朗读进度，无需重新解析 |
| **主题与本地化** | 明暗配色、字体、各类组件样式、背景模式、自定义按钮文案和提示标题 |
| **可扩展语法** | 自定义块/行内语法、引用标签、命名组件、图表代码围栏、自定义操作按钮 |
| **解析与导出** | LLM/CommonMark/GFM 配置、不可变 AST、结构扫描、Markdown/HTML/纯文本序列化 |
| **文本排版** | 字体缩放、RTL 布局、CJK 语法边界、实体和转义后的原文坐标映射 |

具体语法由解析配置决定。**视觉公式排版、代码着色、图片显示和链接跳转需要接入对应适配器**：
`MathRenderer`、`CodeHighlighter`、`ImageBuilder` 和 `LinkHandler`。
未接入时分别显示 LaTeX 原文、无高亮代码和图片替代文本，链接不执行跳转。
引用标签、Mermaid/PlantUML 等业务组件可以通过扩展接口实现，并非库内置的渲染引擎。

## 渲染预览

![Markstream 实际渲染：富文本、任务列表、提示、代码、表格和 HTML](https://github.com/Chevey339/markstream/releases/download/v0.1.0/markstream-preview.png)

预览使用库内置组件实际渲染，未接入业务侧公式或代码高亮适配器。

## 安装

```sh
flutter pub add markstream
```

```yaml
dependencies:
  markstream: ^0.1.0
```

要求 Flutter **3.44.9+**、Dart **3.12.1+**（低于 4.0.0）。
运行时仅依赖 Flutter 和 `lucide_icons_flutter`。

## 快速接入

```dart
import 'package:flutter/material.dart';
import 'package:markstream/markstream.dart';

void main() => runApp(
  const MaterialApp(
    home: Scaffold(
      body: SelectionArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: MarkstreamView(source: '# 你好\n\n支持 **Markdown** 和 `代码`。'),
        ),
      ),
    ),
  ),
);
```

应用提供外层滚动容器、`SelectionArea` 和选择菜单，视图按内容确定高度。

## 流式输出

```dart
MarkstreamView(
  source: accumulatedMarkdown,
  streaming: isReceiving,
)
```

`source` 每次传入**当前已收到的累计全文**，不是最后一个 token；结束后将 `streaming`
设为 `false`。已完成的前置块保留身份，尚在生成的尾部继续更新。
需要直接操作 AST 时，可以使用 `IncrementalDocument` 并通过 `document:` 传入快照。

## 保留 Markdown 的选区复制

在页面状态中创建 `MarkstreamSelectionController`，通过 `selectionController:` 交给视图。
它提供 `hasSelection`、`selectedPlainText`、`selectedMarkdown` 和 `copySelectionAsMarkdown()`。
同一个控制器可以管理同一选择区域中的多个视图，按显示顺序复制；页面销毁时释放控制器。

自定义内联组件可以通过 `SelectableSpanAdapter` 和明确的文本映射参与选择。
更多细节见 [渲染与选择说明](doc/rendering.md)。

## 定制与扩展

- 使用 `MarkstreamTheme` 配置字体、配色、背景和组件样式，使用 `MarkstreamLabels` 配置文案。
- 使用四种渲染适配器接入现有高亮器、公式组件、图片缓存、路由或 URL 打开逻辑。
- 使用 `MarkstreamExtensions` 注册引用标签、内联组件、自定义卡片和代码围栏渲染器。
- 使用代码/表格操作接口实现保存、分享与导出，表格接口提供完整 PNG 截图回调。
- 使用 `highlightRanges` 按原文坐标高亮搜索结果或朗读范围。

[完整指南](doc/guide.md) 说明了语法配置、接口契约、主题、HTML 范围和序列化。

## 平台和验证

使用 Flutter 原生组件，无原生平台插件，面向 **Android、iOS、macOS、Windows、Linux 和 Web**。
独立版本已在 Flutter 3.47.6 / Dart 3.13.5 上通过 **309 项库测试、2 项示例测试**、
静态分析，以及 macOS/Web 构建；控件测试覆盖桌面与 Android 风格选择、字体缩放、RTL 和混合内容。
具体应用仍需在自己的目标设备上验证原生交互。

CommonMark/GFM 是解析配置，并不表示完全符合规范；
[已知差异](https://github.com/Chevey339/markstream/blob/main/test/core/spec/known_deviations.txt) 已公开记录。
HTML 支持安全子集，不是浏览器 HTML/CSS/JavaScript 引擎。

## 运行示例

```sh
git clone https://github.com/Chevey339/markstream.git
cd markstream/example
flutter pub get
flutter run -d macos
```

也可运行 `flutter run -d chrome`。示例支持实时编辑、模拟流式输出、选区复制，
宽窗口并排显示源码和预览，窄窗口使用标签切换。

[性能基准](https://github.com/Chevey339/markstream/blob/main/test/perf/README.md)
单独执行并记录测量边界，不以运行时间断言正确性。
Kelivo 继续使用自己的本地副本，两边按需同步，详见 [来源与维护](UPSTREAM.md)。

## 许可证

沿用原项目的 [AGPL-3.0](LICENSE)。第三方材料保留各自许可证，见
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。
