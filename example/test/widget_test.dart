import 'package:flutter_test/flutter_test.dart';
import 'package:toast/toast.dart';
import 'package:toast_example/main.dart';

void main() {
  tearDown(() {
    Toast.dismiss();
    Toast.hideLoading();
  });

  testWidgets('example app shows a toast from local package', (tester) async {
    await tester.pumpWidget(const ToastExampleApp());

    expect(find.text('Toast 配置'), findsOneWidget);
    expect(find.text('顶部'), findsOneWidget);
    expect(find.text('居中'), findsOneWidget);
    expect(find.text('底部'), findsOneWidget);
    expect(find.text('显示时长'), findsOneWidget);
    expect(find.text('点击 Toast 可关闭'), findsOneWidget);

    await tester.ensureVisible(find.text('显示 Toast'));
    await tester.tap(find.text('显示 Toast'));
    await tester.pump();

    expect(find.text('这是一条默认 Toast'), findsOneWidget);

    Toast.dismiss();
    await tester.pump();
  });

  testWidgets('example app shows a custom toast view', (tester) async {
    await tester.pumpWidget(const ToastExampleApp());

    await tester.ensureVisible(find.text('显示自定义 View Toast'));
    await tester.tap(find.text('显示自定义 View Toast'));
    await tester.pump();

    expect(find.text('自定义内容'), findsOneWidget);

    await tester.tap(find.text('关闭'));
    await tester.pumpAndSettle();

    expect(find.text('自定义内容'), findsNothing);
  });

  testWidgets('example app shows and hides loading', (tester) async {
    await tester.pumpWidget(const ToastExampleApp());

    await tester.ensureVisible(find.text('显示 Loading'));
    await tester.tap(find.text('显示 Loading'));
    await tester.pump();

    expect(find.byType(LoadingSpinner), findsOneWidget);
    expect(find.text('加载中...'), findsNothing);

    await tester.pump(const Duration(seconds: 10));

    expect(find.byType(LoadingSpinner), findsNothing);
  });

  testWidgets('example app shows toast on route test page', (tester) async {
    await tester.pumpWidget(const ToastExampleApp());

    await tester.ensureVisible(find.text('打开页面切换测试'));
    await tester.tap(find.text('打开页面切换测试'));
    await tester.pumpAndSettle();

    expect(find.text('页面切换测试'), findsOneWidget);

    await tester.ensureVisible(find.text('子页面显示 Toast'));
    await tester.tap(find.text('子页面显示 Toast'));
    await tester.pump();

    expect(find.text('子页面 Toast'), findsOneWidget);

    Toast.dismiss();
    await tester.pump();
  });
}
