# markstream

面向流式内容的 Flutter Markdown 库，提供增量解析、原生渲染、跨内容选择，
以及保留 Markdown 格式的选区复制。

这是从 Kelivo 中提取的独立项目。`lib/` 沿用来源快照的实现，仅三处文件经过 Dart 格式化；
Kelivo 仍然使用它自己的 `dependencies/markstream`，两边独立维护。
来源提交和同步规则见 [UPSTREAM.md](UPSTREAM.md)。

## 接入

当前项目尚未发布到 pub.dev。其他 Flutter 项目可以通过本地路径接入：

```yaml
dependencies:
  markstream:
    path: ../markstream
```

```dart
import 'package:flutter/material.dart';
import 'package:markstream/markstream.dart';

// 放在 MaterialApp 内；由应用提供选择区域及滚动容器。
SelectionArea(
  child: SingleChildScrollView(
    child: MarkstreamView(
      source: '# Hello\n\n支持 **Markdown**。',
    ),
  ),
)
```

流式更新时，`source` 传入当前累计收到的全文，`streaming` 设为 `true`；
结束后设为 `false`。完整的可运行示例见 [example](example/README.md)。

## 能力与边界

- 解析层：不可变 AST、UTF-16 原文坐标、增量更新、Markdown/HTML/纯文本导出。
- 渲染层：段落、标题、列表、任务项、代码块、表格、提示卡片、折叠内容和安全 HTML 子集。
- 选择：文本与内联组件共同参与选择，可通过 `MarkstreamSelectionController` 复制 Markdown。
- 扩展：代码高亮、公式渲染、图片加载、链接跳转由调用方实现对应接口。

未提供适配器时，代码不高亮、公式显示 LaTeX 源文、图片显示替代文本，链接不跳转。
Kelivo 的引用、图表预览、文件系统和业务设置不包含在独立库中。
CommonMark/GFM 是可选解析配置，不能据此宣称完全符合规范。

## 本地运行

```sh
flutter pub get
dart analyze --fatal-infos lib test
flutter test
cd example
flutter pub get
flutter test
flutter run -d macos
```

示例也提供 Web 入口，可以运行 `flutter build web` 或手动运行 `flutter run -d chrome`。
示例支持编辑 Markdown、模拟流式输出和复制选区；点击链接在应用内展示目标地址。

SDK 约束沿用 Flutter `>=3.44.9`、Dart `>=3.12.1 <4.0.0`。
独立项目的检查使用 Flutter 3.47.6 / Dart 3.13.5，尚未重新验证最低版本。
性能基准需要单独执行，见 [运行方法与测量边界](test/perf/README.md)。

许可证沿用原仓库的 [AGPL-3.0](LICENSE)，第三方材料见
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。
