import 'dart:async';

import 'package:flutter/material.dart';
import 'package:x_toast_plus/toast.dart';

void main() {
  runApp(const ToastExampleApp());
}

class ToastExampleApp extends StatelessWidget {
  const ToastExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toast Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return Toast.init(context, child: child);
      },
      home: const ToastExamplePage(),
    );
  }
}

class ToastExamplePage extends StatefulWidget {
  const ToastExamplePage({super.key});

  @override
  State<ToastExamplePage> createState() => _ToastExamplePageState();
}

class _ToastExamplePageState extends State<ToastExamplePage> {
  ToastPosition _toastPosition = ToastPosition.bottom;
  double _toastDurationSeconds = 2;
  bool _toastDismissible = true;
  Timer? _loadingTimer;

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Toast Example')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Toast Playground',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _ConfigSection(
                    toastPosition: _toastPosition,
                    toastDurationSeconds: _toastDurationSeconds,
                    toastDismissible: _toastDismissible,
                    onPositionChanged: (position) {
                      setState(() => _toastPosition = position);
                    },
                    onDurationChanged: (value) {
                      setState(() => _toastDurationSeconds = value);
                    },
                    onDismissibleChanged: (value) {
                      setState(() => _toastDismissible = value);
                    },
                  ),
                  const SizedBox(height: 20),
                  _ToastAction(
                    icon: Icons.message_rounded,
                    label: '显示 Toast',
                    onPressed: () {
                      Toast.init(
                        context,
                        position: _toastPosition,
                        duration: _toastDuration,
                        dismissible: _toastDismissible,
                      );
                      Toast.show('这是一条默认 Toast这是一条默认 Toast这是一条默认 Toast这是一条默认 Toast');
                    },
                  ),
                  _ToastAction(
                    icon: Icons.widgets_rounded,
                    label: '显示自定义 View Toast',
                    onPressed: () {
                      Toast.init(
                        context,
                        position: _toastPosition,
                        duration: _toastDuration,
                        dismissible: _toastDismissible,
                      );
                      Toast.custom(
                        semanticsLabel: '自定义 View Toast',
                        builder: (context, dismiss) => DecoratedBox(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x26000000),
                                blurRadius: 18,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.bolt_rounded),
                                const SizedBox(width: 10),
                                const Text('自定义内容'),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: dismiss,
                                  child: const Text('关闭'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  _ToastAction(
                    icon: Icons.hourglass_top_rounded,
                    label: '显示 Loading',
                    onPressed: _showLoadingForTenSeconds,
                  ),
                  _ToastAction(
                    icon: Icons.open_in_new_rounded,
                    label: '打开页面切换测试',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ToastRouteTestPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Duration get _toastDuration =>
      Duration(seconds: _toastDurationSeconds.round());

  void _showLoadingForTenSeconds() {
    Toast.showLoading();
    _loadingTimer?.cancel();
    _loadingTimer = Timer(const Duration(seconds: 10), Toast.hideLoading);
  }
}

class ToastRouteTestPage extends StatefulWidget {
  const ToastRouteTestPage({super.key});

  @override
  State<ToastRouteTestPage> createState() => _ToastRouteTestPageState();
}

class _ToastRouteTestPageState extends State<ToastRouteTestPage> {
  ToastPosition _toastPosition = ToastPosition.bottom;
  double _toastDurationSeconds = 2;
  bool _toastDismissible = true;
  Timer? _loadingTimer;

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('页面切换测试')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Route Toast Test',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '在这个页面触发 Toast 后，可以返回上一页观察页面切换时的显示效果。',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  _ConfigSection(
                    toastPosition: _toastPosition,
                    toastDurationSeconds: _toastDurationSeconds,
                    toastDismissible: _toastDismissible,
                    onPositionChanged: (position) {
                      setState(() => _toastPosition = position);
                    },
                    onDurationChanged: (value) {
                      setState(() => _toastDurationSeconds = value);
                    },
                    onDismissibleChanged: (value) {
                      setState(() => _toastDismissible = value);
                    },
                  ),
                  const SizedBox(height: 20),
                  _ToastAction(
                    icon: Icons.message_rounded,
                    label: '子页面显示 Toast',
                    onPressed: () {
                      Toast.init(
                        context,
                        position: _toastPosition,
                        duration: _toastDuration,
                        dismissible: _toastDismissible,
                      );
                      Toast.show('子页面 Toast');
                    },
                  ),
                  _ToastAction(
                    icon: Icons.widgets_rounded,
                    label: '子页面自定义 View',
                    onPressed: () {
                      Toast.init(
                        context,
                        position: _toastPosition,
                        duration: _toastDuration,
                        dismissible: _toastDismissible,
                      );
                      Toast.custom(
                        semanticsLabel: '子页面自定义 Toast',
                        builder: (context, dismiss) => DecoratedBox(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x26000000),
                                blurRadius: 18,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.route_rounded),
                                const SizedBox(width: 10),
                                const Text('子页面自定义内容'),
                                IconButton(
                                  tooltip: '关闭',
                                  onPressed: dismiss,
                                  icon: const Icon(Icons.close_rounded),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  _ToastAction(
                    icon: Icons.hourglass_top_rounded,
                    label: '子页面显示 Loading',
                    onPressed: _showLoadingForTenSeconds,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Duration get _toastDuration =>
      Duration(seconds: _toastDurationSeconds.round());

  void _showLoadingForTenSeconds() {
    Toast.showLoading();
    _loadingTimer?.cancel();
    _loadingTimer = Timer(const Duration(seconds: 10), Toast.hideLoading);
  }
}

class _ConfigSection extends StatelessWidget {
  const _ConfigSection({
    required this.toastPosition,
    required this.toastDurationSeconds,
    required this.toastDismissible,
    required this.onPositionChanged,
    required this.onDurationChanged,
    required this.onDismissibleChanged,
  });

  final ToastPosition toastPosition;
  final double toastDurationSeconds;
  final bool toastDismissible;
  final ValueChanged<ToastPosition> onPositionChanged;
  final ValueChanged<double> onDurationChanged;
  final ValueChanged<bool> onDismissibleChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Toast 配置',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        SegmentedButton<ToastPosition>(
          segments: const [
            ButtonSegment(
              value: ToastPosition.top,
              icon: Icon(Icons.vertical_align_top_rounded),
              label: Text('顶部'),
            ),
            ButtonSegment(
              value: ToastPosition.center,
              icon: Icon(Icons.center_focus_strong_rounded),
              label: Text('居中'),
            ),
            ButtonSegment(
              value: ToastPosition.bottom,
              icon: Icon(Icons.vertical_align_bottom_rounded),
              label: Text('底部'),
            ),
          ],
          selected: {toastPosition},
          onSelectionChanged: (selection) {
            onPositionChanged(selection.first);
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text('显示时长'),
            Expanded(
              child: Slider(
                value: toastDurationSeconds,
                min: 1,
                max: 6,
                divisions: 5,
                label: '${toastDurationSeconds.round()} 秒',
                onChanged: onDurationChanged,
              ),
            ),
            SizedBox(
              width: 48,
              child: Text('${toastDurationSeconds.round()} 秒'),
            ),
          ],
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('点击 Toast 可关闭'),
          value: toastDismissible,
          onChanged: onDismissibleChanged,
        ),
      ],
    );
  }
}

class _ToastAction extends StatelessWidget {
  const _ToastAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
