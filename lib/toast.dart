library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

enum ToastType { success, error, warning, info }

enum ToastPosition { top, center, bottom }

enum ToastThemeMode { light, dark }

typedef ToastViewBuilder =
    Widget Function(BuildContext context, VoidCallback dismiss);

class ToastStyle {
  const ToastStyle({
    this.backgroundColor = const Color(0xE6FFFFFF),
    this.foregroundColor = Colors.black87,
    this.borderRadius = const BorderRadius.all(Radius.circular(1000)),
    this.padding = const EdgeInsets.symmetric(horizontal: 16,vertical: 12),
    this.contentPadding,
    this.maxWidth = 320,
    this.textStyle,
    this.shadows = const [
      BoxShadow(color: Color(0x26000000), blurRadius: 16, offset: Offset(0, 6)),
    ],
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? contentPadding;
  final double maxWidth;
  final TextStyle? textStyle;
  final List<BoxShadow> shadows;
}

class LoadingStyle {
  const LoadingStyle({
    this.backgroundColor = const Color(0xE6FFFFFF),
    this.foregroundColor = Colors.black87,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.padding = const EdgeInsets.all(18),
    this.spinnerSize = 36,
    this.spinnerStrokeWidth = 2.4,
    this.spinnerTickCount = 8,
    this.spinnerTickHeight = 5,
    this.textStyle,
    this.shadows = const [
      BoxShadow(color: Color(0x26000000), blurRadius: 16, offset: Offset(0, 6)),
    ],
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry padding;
  final double spinnerSize;
  final double spinnerStrokeWidth;
  final int spinnerTickCount;
  final double spinnerTickHeight;
  final TextStyle? textStyle;
  final List<BoxShadow> shadows;
}

class ToastThemeData {
  const ToastThemeData({
    this.toastStyle = const ToastStyle(
      backgroundColor: Color(0xE6FFFFFF),
      foregroundColor: Colors.black87,
    ),
    this.loadingStyle = const LoadingStyle(),
    this.loadingMessage = '',
    this.loadingMaskColor = Colors.black,
    this.loadingMaskOpacity = 0.4,
    this.allowBackgroundInteraction = false,
  });

  final ToastStyle toastStyle;
  final LoadingStyle loadingStyle;
  final String loadingMessage;
  final Color loadingMaskColor;
  final double loadingMaskOpacity;
  final bool allowBackgroundInteraction;

  static const ToastThemeData light = ToastThemeData();

  static const ToastThemeData dark = ToastThemeData(
    toastStyle: ToastStyle(
      backgroundColor: Color(0xE6000000),
      foregroundColor: Colors.white,
    ),
    loadingStyle: LoadingStyle(
      backgroundColor: Color(0xE6000000),
      foregroundColor: Colors.white,
    ),
  );

  ToastThemeData copyWith({
    ToastStyle? toastStyle,
    LoadingStyle? loadingStyle,
    String? loadingMessage,
    Color? loadingMaskColor,
    double? loadingMaskOpacity,
    bool? allowBackgroundInteraction,
  }) {
    return ToastThemeData(
      toastStyle: toastStyle ?? this.toastStyle,
      loadingStyle: loadingStyle ?? this.loadingStyle,
      loadingMessage: loadingMessage ?? this.loadingMessage,
      loadingMaskColor: loadingMaskColor ?? this.loadingMaskColor,
      loadingMaskOpacity: loadingMaskOpacity ?? this.loadingMaskOpacity,
      allowBackgroundInteraction:
          allowBackgroundInteraction ?? this.allowBackgroundInteraction,
    );
  }
}

class Toast {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<OverlayState> _hostOverlayKey =
      GlobalKey<OverlayState>();

  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;
  static GlobalKey<NavigatorState> _navigatorKey = navigatorKey;
  static OverlayState? _overlayState;
  static ToastThemeMode _themeMode = ToastThemeMode.light;
  static ToastThemeData _lightTheme = ToastThemeData.light;
  static ToastThemeData _darkTheme = ToastThemeData.dark;
  static ToastPosition _defaultPosition = ToastPosition.bottom;
  static Duration _defaultDuration = const Duration(seconds: 2);
  static bool _defaultDismissible = true;

  static Widget init(
    BuildContext context, {
    Widget? child,
    GlobalKey<NavigatorState>? navigatorKey,
    ToastThemeMode? themeMode,
    ToastThemeData? lightTheme,
    ToastThemeData? darkTheme,
    ToastPosition? position,
    Duration? duration,
    bool? dismissible,
    ToastStyle? style,
    String? loadingMessage,
    LoadingStyle? loadingStyle,
    Color? loadingMaskColor,
    double? loadingMaskOpacity,
    bool? allowBackgroundInteraction,
  }) {
    _overlayState = Overlay.maybeOf(context, rootOverlay: true);
    _navigatorKey = navigatorKey ?? _navigatorKey;
    configure(
      themeMode: themeMode,
      lightTheme: lightTheme,
      darkTheme: darkTheme,
      position: position,
      duration: duration,
      dismissible: dismissible,
      style: style,
      loadingMessage: loadingMessage,
      loadingStyle: loadingStyle,
      loadingMaskColor: loadingMaskColor,
      loadingMaskOpacity: loadingMaskOpacity,
      allowBackgroundInteraction: allowBackgroundInteraction,
    );

    if (child != null) {
      return _ToastHost(child: child);
    }

    return const SizedBox.shrink();
  }

  static void configure({
    ToastThemeMode? themeMode,
    ToastThemeData? lightTheme,
    ToastThemeData? darkTheme,
    ToastPosition? position,
    Duration? duration,
    bool? dismissible,
    ToastStyle? style,
    String? loadingMessage,
    LoadingStyle? loadingStyle,
    Color? loadingMaskColor,
    double? loadingMaskOpacity,
    bool? allowBackgroundInteraction,
  }) {
    _themeMode = themeMode ?? _themeMode;
    _lightTheme = lightTheme ?? _lightTheme;
    _darkTheme = darkTheme ?? _darkTheme;
    _defaultPosition = position ?? _defaultPosition;
    _defaultDuration = duration ?? _defaultDuration;
    _defaultDismissible = dismissible ?? _defaultDismissible;

    if (style != null ||
        loadingMessage != null ||
        loadingStyle != null ||
        loadingMaskColor != null ||
        loadingMaskOpacity != null ||
        allowBackgroundInteraction != null) {
      final nextTheme = _activeTheme.copyWith(
        toastStyle: style,
        loadingMessage: loadingMessage,
        loadingStyle: loadingStyle,
        loadingMaskColor: loadingMaskColor,
        loadingMaskOpacity: loadingMaskOpacity,
        allowBackgroundInteraction: allowBackgroundInteraction,
      );

      if (_themeMode == ToastThemeMode.light) {
        _lightTheme = nextTheme;
      } else {
        _darkTheme = nextTheme;
      }
    }
  }

  static ToastThemeData get _activeTheme {
    switch (_themeMode) {
      case ToastThemeMode.light:
        return _lightTheme;
      case ToastThemeMode.dark:
        return _darkTheme;
    }
  }

  static void show(
    String message, {
    BuildContext? context,
    ToastType type = ToastType.info,
    ToastPosition? position,
    Duration? duration,
    bool? dismissible,
    ToastStyle? style,
  }) {
    _showOverlay(
      context,
      position: position ?? _defaultPosition,
      duration: duration ?? _defaultDuration,
      dismissible: dismissible ?? _defaultDismissible,
      semanticsLabel: message,
      builder: (context, _) => _DefaultToastView(
        message: message,
        style: style ?? _activeTheme.toastStyle,
      ),
    );
  }

  static void custom({
    BuildContext? context,
    Widget? child,
    ToastViewBuilder? builder,
    ToastPosition? position,
    Duration? duration,
    bool? dismissible,
    String? semanticsLabel,
  }) {
    assert(
      child != null || builder != null,
      'Toast.custom requires either child or builder.',
    );

    _showOverlay(
      context,
      position: position ?? _defaultPosition,
      duration: duration ?? _defaultDuration,
      dismissible: dismissible ?? _defaultDismissible,
      semanticsLabel: semanticsLabel,
      builder: builder ?? (_, _) => child!,
    );
  }

  static void success(
    String message, {
    BuildContext? context,
    ToastPosition? position,
    Duration? duration,
    ToastStyle? style,
  }) {
    show(
      message,
      context: context,
      type: ToastType.success,
      position: position,
      duration: duration,
      style: style,
    );
  }

  static void error(
    String message, {
    BuildContext? context,
    ToastPosition? position,
    Duration? duration,
    ToastStyle? style,
  }) {
    show(
      message,
      context: context,
      type: ToastType.error,
      position: position,
      duration: duration,
      style: style,
    );
  }

  static void warning(
    String message, {
    BuildContext? context,
    ToastPosition? position,
    Duration? duration,
    ToastStyle? style,
  }) {
    show(
      message,
      context: context,
      type: ToastType.warning,
      position: position,
      duration: duration,
      style: style,
    );
  }

  static void info(
    String message, {
    BuildContext? context,
    ToastPosition? position,
    Duration? duration,
    ToastStyle? style,
  }) {
    show(
      message,
      context: context,
      type: ToastType.info,
      position: position,
      duration: duration,
      style: style,
    );
  }

  static void dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _currentEntry?.remove();
    _currentEntry = null;
  }

  static void showLoading({
    BuildContext? context,
    String? message,
    Widget? child,
    LoadingStyle? style,
    Color? maskColor,
    double? maskOpacity,
    bool? allowBackgroundInteraction,
  }) {
    _Loading.show(
      context: context,
      message: message ?? _activeTheme.loadingMessage,
      child: child,
      style: style ?? _activeTheme.loadingStyle,
      maskColor: maskColor ?? _activeTheme.loadingMaskColor,
      maskOpacity: maskOpacity ?? _activeTheme.loadingMaskOpacity,
      allowBackgroundInteraction:
          allowBackgroundInteraction ?? _activeTheme.allowBackgroundInteraction,
    );
  }

  static void hideLoading() {
    _Loading.hide();
  }

  static void _showOverlay(
    BuildContext? context, {
    required ToastPosition position,
    required Duration duration,
    required bool dismissible,
    required ToastViewBuilder builder,
    String? semanticsLabel,
  }) {
    dismiss();

    final overlay = _overlayOf(context);
    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _ToastOverlay(
        position: position,
        dismissible: dismissible,
        semanticsLabel: semanticsLabel,
        builder: builder,
        onDismiss: () {
          if (_currentEntry == entry) {
            dismiss();
          }
        },
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
    _dismissTimer = Timer(duration, dismiss);
  }

  static OverlayState _overlayOf(BuildContext? context) {
    if (context != null) {
      return Overlay.of(context, rootOverlay: true);
    }

    if (_overlayState != null) {
      return _overlayState!;
    }

    final hostOverlay = _hostOverlayKey.currentState;
    if (hostOverlay != null) {
      return hostOverlay;
    }

    final navigatorOverlay = _navigatorKey.currentState?.overlay;
    if (navigatorOverlay != null) {
      return navigatorOverlay;
    }

    final navigatorContext = _navigatorKey.currentContext;
    if (navigatorContext != null) {
      return Overlay.of(navigatorContext, rootOverlay: true);
    }

    throw FlutterError.fromParts([
      ErrorSummary('Toast needs an Overlay context.'),
      ErrorDescription(
        'Call Toast.init(context) from a widget below MaterialApp/Navigator, '
        'call Toast.init(navigatorKey: yourNavigatorKey) and pass the same key '
        'to MaterialApp.navigatorKey, or pass context: context when calling Toast.',
      ),
    ]);
  }
}

class _ToastHost extends StatelessWidget {
  const _ToastHost({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Overlay(
      key: Toast._hostOverlayKey,
      initialEntries: [OverlayEntry(builder: (context) => child)],
    );
  }
}

class _Loading {
  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;

  static void show({
    BuildContext? context,
    String message = '',
    Widget? child,
    LoadingStyle style = const LoadingStyle(),
    Color maskColor = Colors.black,
    double maskOpacity = 0.4,
    bool allowBackgroundInteraction = false,
  }) {
    hide();

    final overlay = Toast._overlayOf(context);
    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _LoadingOverlay(
        maskColor: maskColor,
        maskOpacity: maskOpacity,
        allowBackgroundInteraction: allowBackgroundInteraction,
        child: child ?? _DefaultLoadingView(message: message, style: style),
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
  }

  static void hide() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class LoadingSpinner extends StatefulWidget {
  const LoadingSpinner({
    super.key,
    this.size = 48,
    this.color = Colors.white,
    this.strokeWidth = 2,
    this.duration = const Duration(milliseconds: 1000),
    this.tickCount = 8,
    this.tickHeight = 5,
  });

  final double size;
  final Color color;
  final double strokeWidth;
  final Duration duration;
  final int tickCount;
  final double tickHeight;

  @override
  State<LoadingSpinner> createState() => _LoadingSpinnerState();
}

class _LoadingSpinnerState extends State<LoadingSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void didUpdateWidget(covariant LoadingSpinner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _SpinnerPainter(
              color: widget.color,
              strokeWidth: widget.strokeWidth,
              tickCount: widget.tickCount,
              tickHeight: widget.tickHeight,
              animationValue: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _DefaultLoadingView extends StatelessWidget {
  const _DefaultLoadingView({required this.message, required this.style});

  final String message;
  final LoadingStyle style;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: style.foregroundColor,
      fontWeight: FontWeight.w500,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: style.borderRadius,
        boxShadow: style.shadows,
      ),
      child: Padding(
        padding: style.padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LoadingSpinner(
              size: style.spinnerSize,
              color: style.foregroundColor,
              strokeWidth: style.spinnerStrokeWidth,
              tickCount: style.spinnerTickCount,
              tickHeight: style.spinnerTickHeight,
            ),
            if (message.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: style.textStyle ?? textStyle,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LoadingOverlay extends StatefulWidget {
  const _LoadingOverlay({
    required this.child,
    required this.maskColor,
    required this.maskOpacity,
    required this.allowBackgroundInteraction,
  });

  final Widget child;
  final Color maskColor;
  final double maskOpacity;
  final bool allowBackgroundInteraction;

  @override
  State<_LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<_LoadingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
      reverseDuration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(
      begin: 0.96,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maskOpacity = widget.maskOpacity.clamp(0.0, 1.0).toDouble();

    return Positioned.fill(
      child: Stack(
        children: [
          IgnorePointer(
            ignoring: widget.allowBackgroundInteraction,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: ColoredBox(
                color: widget.maskColor.withValues(alpha: maskOpacity),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Semantics(
                  container: true,
                  liveRegion: true,
                  label: 'Loading',
                  child: Material(
                    color: Colors.transparent,
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  _SpinnerPainter({
    required this.color,
    required this.strokeWidth,
    required this.tickCount,
    required this.tickHeight,
    required this.animationValue,
  });

  final Color color;
  final double strokeWidth;
  final int tickCount;
  final double tickHeight;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final activeIndex = (animationValue * tickCount).floor() % tickCount;

    for (var i = 0; i < tickCount; i++) {
      final angle = (i * 2 * math.pi) / tickCount - math.pi / 2;
      final endRadius = radius * 0.75;
      final startRadius = endRadius - tickHeight;

      final start = Offset(
        center.dx + startRadius * math.cos(angle),
        center.dy + startRadius * math.sin(angle),
      );
      final end = Offset(
        center.dx + endRadius * math.cos(angle),
        center.dy + endRadius * math.sin(angle),
      );

      var indexDiff = (activeIndex - i) % tickCount;
      if (indexDiff < 0) {
        indexDiff += tickCount;
      }

      final opacity = 1 - (indexDiff / tickCount) * 0.9;
      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpinnerPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.tickCount != tickCount ||
        oldDelegate.tickHeight != tickHeight;
  }
}

class _DefaultToastView extends StatelessWidget {
  const _DefaultToastView({required this.message, required this.style});

  final String message;
  final ToastStyle style;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: style.foregroundColor,
      fontWeight: FontWeight.w500,
    );

    return DecoratedBox(
      decoration: const BoxDecoration(),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: style.maxWidth),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: style.backgroundColor,
            borderRadius: style.borderRadius,
            boxShadow: style.shadows,
          ),
          child: Padding(
            padding: style.contentPadding ?? style.padding,
            child: Text(
              message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: style.textStyle ?? textStyle,
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastOverlay extends StatefulWidget {
  const _ToastOverlay({
    required this.position,
    required this.dismissible,
    required this.builder,
    required this.onDismiss,
    this.semanticsLabel,
  });

  final ToastPosition position;
  final bool dismissible;
  final ToastViewBuilder builder;
  final VoidCallback onDismiss;
  final String? semanticsLabel;

  @override
  State<_ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<_ToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
    _slideAnimation = Tween<Offset>(
      begin: _offsetFor(widget.position),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    if (!_controller.isDismissed) {
      await _controller.reverse();
    }
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final toast = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: widget.builder(context, _close),
    );

    return SafeArea(
      child: Align(
        alignment: _alignmentFor(widget.position),
        child: Padding(
          padding: _paddingFor(widget.position),
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Semantics(
                container: true,
                liveRegion: true,
                label: widget.semanticsLabel,
                child: Material(
                  color: Colors.transparent,
                  child: GestureDetector(
                    onTap: widget.dismissible ? _close : null,
                    child: toast,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Alignment _alignmentFor(ToastPosition position) {
  switch (position) {
    case ToastPosition.top:
      return Alignment.topCenter;
    case ToastPosition.center:
      return Alignment.center;
    case ToastPosition.bottom:
      return Alignment.bottomCenter;
  }
}

Offset _offsetFor(ToastPosition position) {
  switch (position) {
    case ToastPosition.top:
      return const Offset(0, -0.08);
    case ToastPosition.center:
      return const Offset(0, 0.03);
    case ToastPosition.bottom:
      return const Offset(0, 0.08);
  }
}

EdgeInsets _paddingFor(ToastPosition position) {
  switch (position) {
    case ToastPosition.top:
      return const EdgeInsets.fromLTRB(24, 24, 24, 0);
    case ToastPosition.center:
      return const EdgeInsets.symmetric(horizontal: 24);
    case ToastPosition.bottom:
      return const EdgeInsets.fromLTRB(24, 0, 24, 48);
  }
}
