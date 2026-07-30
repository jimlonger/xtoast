# Toast Plugin

一个轻量、零依赖的 Flutter Toast 工具，基于 `OverlayEntry` 实现，适合直接放进现有 Flutter 项目使用。

## 功能

- 支持 `success`、`error`、`warning`、`info` 四种状态。
- 支持顶部、居中、底部三个显示位置。
- 自动消失，也可以点击或点关闭按钮手动关闭。
- 同一时间只显示一个 Toast，新的提示会替换旧提示。
- 支持默认文本 Toast，也支持传入自定义 View。
- 支持独立的 Loading HUD，默认居中显示，和 Toast 显示/隐藏互不影响。
- 支持白色/黑色两套主题，默认白色模式，Toast 和 Loading 样式可统一配置。

## 使用

```dart
import 'package:simple_toast/toast.dart';

void main() {
  runApp(const MyApp());
}

class AppPage extends StatelessWidget {
  const AppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return Toast.init(context, child: child);
      },
      home: const AppPage(),
    );
  }
}

Toast.show('这是一条默认 Toast');

Toast.show(
  '这是一条顶部提示',
  type: ToastType.info,
  position: ToastPosition.top,
  duration: const Duration(seconds: 2),
);

Toast.dismiss();
```

Flutter 没有公开的全局 API 可以让插件自动可靠获取应用 Navigator。使用 `MaterialApp.builder` 返回 `Toast.init(context, child: child)` 时，插件会创建自己的全局 Overlay 容器，因此后续调用 `Toast.show(...)` / `Toast.showLoading()` 不需要再传 `context`。

## 主题配置

默认是白色模式。可以在初始化时配置主题模式和两套主题：

```dart
Toast.init(
  context,
  child: child,
  themeMode: ToastThemeMode.light,
  lightTheme: const ToastThemeData(
    toastStyle: ToastStyle(
      backgroundColor: Color(0xE6FFFFFF),
      foregroundColor: Colors.black87,
      borderRadius: BorderRadius.all(Radius.circular(20)),
      contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    ),
    loadingStyle: LoadingStyle(
      backgroundColor: Color(0xE6FFFFFF),
      foregroundColor: Colors.black87,
      borderRadius: BorderRadius.all(Radius.circular(12)),
      textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    ),
    loadingMessage: '',
    loadingMaskColor: Colors.black,
    loadingMaskOpacity: 0.4,
    allowBackgroundInteraction: false,
  ),
  darkTheme: const ToastThemeData(
    toastStyle: ToastStyle(
      backgroundColor: Color(0xE6000000),
      foregroundColor: Colors.white,
      textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    ),
    loadingStyle: LoadingStyle(
      backgroundColor: Color(0xE6000000),
      foregroundColor: Colors.white,
      textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    ),
  ),
);
```

也可以后续再次配置，最后一次传入的值生效：

```dart
Toast.configure(
  themeMode: ToastThemeMode.dark,
  style: const ToastStyle(
    backgroundColor: Color(0xE6000000),
    foregroundColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
  ),
  loadingStyle: const LoadingStyle(
    backgroundColor: Color(0xE6000000),
    foregroundColor: Colors.white,
  ),
);
```

## Loading

显示默认 loading，默认居中显示、带蒙层、不显示文字：

```dart
Toast.showLoading();
```

显示文字、配置 loading 背景和圆角：

```dart
Toast.showLoading(
  message: '加载数据中',
  style: const LoadingStyle(
    backgroundColor: Color(0xE6FFFFFF),
    borderRadius: BorderRadius.all(Radius.circular(12)),
  ),
);
```

配置蒙层和蒙层下方是否可点击：

```dart
Toast.showLoading(
  maskColor: Colors.black,
  maskOpacity: 0.4,
  allowBackgroundInteraction: false,
);
```

需要提前关闭时：

```dart
Toast.hideLoading();
```

Loading 使用独立的 Overlay 管理，不会被 `Toast.dismiss()` 关闭；普通 Toast 也不会被 `Toast.hideLoading()` 关闭。
插件层不会自动关闭 Loading；需要业务主动调用 `Toast.hideLoading()`。测试页中的 Loading 按钮为了演示，会在 10 秒后主动调用 `Toast.hideLoading()`。

## 自定义 View

直接传入 Widget：

```dart
Toast.custom(
  child: DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Padding(
      padding: EdgeInsets.all(12),
      child: Text('自定义 Toast'),
    ),
  ),
);
```

需要主动关闭时，仍然使用 `Toast.custom` 的 builder 参数：

```dart
Toast.custom(
  builder: (context, dismiss) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('已保存'),
        TextButton(
          onPressed: dismiss,
          child: const Text('关闭'),
        ),
      ],
    );
  },
);
```

## 示例项目

项目包含一个可运行示例：

```bash
cd example
flutter run
```

如果本机连接了多个设备，也可以指定平台：

```bash
flutter run -d macos
flutter run -d chrome
flutter run -d ios
flutter run -d android
```

也可以单独运行示例测试：

```bash
cd example
flutter test
```
