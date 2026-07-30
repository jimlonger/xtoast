import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xtoast/main.dart';
import 'package:xtoast/toast.dart';

void main() {
  tearDown(() {
    Toast.dismiss();
    Toast.hideLoading();
    Toast.configure(
      themeMode: ToastThemeMode.light,
      lightTheme: ToastThemeData.light,
      darkTheme: ToastThemeData.dark,
      position: ToastPosition.bottom,
      duration: const Duration(seconds: 2),
      dismissible: true,
    );
  });

  testWidgets('shows a toast from the demo page', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Toast 配置'), findsOneWidget);
    expect(find.text('顶部'), findsOneWidget);
    expect(find.text('居中'), findsOneWidget);
    expect(find.text('底部'), findsOneWidget);
    expect(find.text('显示时长'), findsOneWidget);
    expect(find.text('点击 Toast 可关闭'), findsOneWidget);

    await tester.tap(find.text('显示 Toast'));
    await tester.pump();

    expect(find.text('这是一条默认 Toast'), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsNothing);
    expect(_decoratedBoxWithColor(const Color(0xE6FFFFFF)), findsOneWidget);
    expect(
      _decoratedBoxWithRadius(const BorderRadius.all(Radius.circular(1000))),
      findsOneWidget,
    );

    Toast.dismiss();
    await tester.pump();
  });

  testWidgets('dismisses the current toast automatically', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('显示 Toast'));
    await tester.pump();

    expect(find.text('这是一条默认 Toast'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));

    expect(find.text('这是一条默认 Toast'), findsNothing);
  });

  testWidgets('shows a custom toast view', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.ensureVisible(find.text('自定义 View'));
    await tester.tap(find.text('自定义 View'));
    await tester.pump();

    expect(find.text('这是自定义 Toast View'), findsOneWidget);
    expect(find.byIcon(Icons.celebration_rounded), findsOneWidget);

    await tester.tap(find.byTooltip('关闭'));
    await tester.pumpAndSettle();

    expect(find.text('这是自定义 Toast View'), findsNothing);
  });

  testWidgets('shows and hides loading independently from toast', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    Toast.showLoading();
    Toast.show('普通 Toast');
    await tester.pump();

    expect(find.byType(LoadingSpinner), findsOneWidget);
    expect(find.text('加载中...'), findsNothing);
    expect(find.text('普通 Toast'), findsOneWidget);

    Toast.dismiss();
    await tester.pump();

    expect(find.byType(LoadingSpinner), findsOneWidget);
    expect(find.text('普通 Toast'), findsNothing);

    Toast.hideLoading();
    await tester.pump();

    expect(find.byType(LoadingSpinner), findsNothing);
  });

  testWidgets('loading closes automatically after 10 seconds', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.ensureVisible(find.text('显示 Loading'));
    await tester.tap(find.text('显示 Loading'));
    await tester.pump();

    expect(find.byType(LoadingSpinner), findsOneWidget);

    await tester.pump(const Duration(seconds: 10));

    expect(find.byType(LoadingSpinner), findsNothing);
  });

  testWidgets('loading shows configured message', (tester) async {
    await tester.pumpWidget(const MyApp());

    Toast.showLoading(message: '加载数据中');
    await tester.pump();

    expect(find.byType(LoadingSpinner), findsOneWidget);
    expect(find.text('加载数据中'), findsOneWidget);

    Toast.hideLoading();
    await tester.pump();
  });

  testWidgets('loading mask opacity is configurable', (tester) async {
    await tester.pumpWidget(const MyApp());

    Toast.showLoading(maskColor: Colors.red, maskOpacity: 0.25);
    await tester.pump();

    final maskFinder = find.byWidgetPredicate((widget) {
      return widget is ColoredBox &&
          widget.color == Colors.red.withValues(alpha: 0.25);
    });

    expect(maskFinder, findsOneWidget);

    Toast.hideLoading();
    await tester.pump();
  });

  testWidgets('loading uses translucent white panel by default', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    Toast.showLoading();
    await tester.pump();

    final panelFinder = find.byWidgetPredicate((widget) {
      return widget is DecoratedBox &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).color == const Color(0xE6FFFFFF);
    });

    expect(panelFinder, findsOneWidget);
    expect(_decoratedBoxWithRadius(BorderRadius.circular(12)), findsOneWidget);

    Toast.hideLoading();
    await tester.pump();
  });

  testWidgets('toast and loading share light mode colors and shadow', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    Toast.show('统一样式 Toast');
    await tester.pump();

    final toastDecoration = _firstBoxDecoration(tester);

    Toast.dismiss();
    Toast.showLoading();
    await tester.pump();

    final loadingDecoration = _firstBoxDecoration(tester);

    expect(toastDecoration.color, loadingDecoration.color);
    expect(toastDecoration.borderRadius, isNot(loadingDecoration.borderRadius));
    expect(toastDecoration.boxShadow, loadingDecoration.boxShadow);

    Toast.hideLoading();
    await tester.pump();
  });

  testWidgets('toast content padding is configurable', (tester) async {
    await tester.pumpWidget(const MyApp());

    Toast.show(
      '自定义间距 Toast',
      style: const ToastStyle(
        contentPadding: EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      ),
    );
    await tester.pump();

    final paddingFinder = find.byWidgetPredicate((widget) {
      return widget is Padding &&
          widget.padding ==
              const EdgeInsets.symmetric(horizontal: 28, vertical: 16);
    });

    expect(paddingFinder, findsOneWidget);

    Toast.dismiss();
    await tester.pump();
  });

  testWidgets('dark mode uses dark toast and loading panels', (tester) async {
    await tester.pumpWidget(const MyApp());

    Toast.configure(themeMode: ToastThemeMode.dark);
    Toast.show('深色 Toast');
    await tester.pump();

    expect(find.text('深色 Toast'), findsOneWidget);
    expect(_decoratedBoxWithColor(const Color(0xE6000000)), findsOneWidget);

    Toast.dismiss();
    Toast.showLoading();
    await tester.pump();

    expect(find.byType(LoadingSpinner), findsOneWidget);
    expect(_decoratedBoxWithColor(const Color(0xE6000000)), findsOneWidget);

    Toast.hideLoading();
    await tester.pump();
  });

  testWidgets('shows toast after navigating to route test page', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.ensureVisible(find.text('打开页面切换测试'));
    await tester.tap(find.text('打开页面切换测试'));
    await tester.pumpAndSettle();

    expect(find.text('页面切换测试'), findsOneWidget);

    await tester.ensureVisible(find.text('子页面显示 Toast'));
    await tester.tap(find.text('子页面显示 Toast'));
    await tester.pump();

    expect(find.text('子页面 Toast'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Toast 插件'), findsOneWidget);
    expect(find.text('子页面 Toast'), findsOneWidget);

    Toast.dismiss();
    await tester.pump();
  });
}

Finder _decoratedBoxWithColor(Color color) {
  return find.byWidgetPredicate((widget) {
    return widget is DecoratedBox &&
        widget.decoration is BoxDecoration &&
        (widget.decoration as BoxDecoration).color == color;
  });
}

Finder _decoratedBoxWithRadius(BorderRadius radius) {
  return find.byWidgetPredicate((widget) {
    return widget is DecoratedBox &&
        widget.decoration is BoxDecoration &&
        (widget.decoration as BoxDecoration).borderRadius == radius;
  });
}

BoxDecoration _firstBoxDecoration(WidgetTester tester) {
  final decoratedBox = tester.widget<DecoratedBox>(
    find.byWidgetPredicate((widget) {
      return widget is DecoratedBox &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).color != null;
    }).first,
  );

  return decoratedBox.decoration as BoxDecoration;
}
