import 'package:fl_clash/auth/auth_controller.dart';
import 'package:fl_clash/auth/models/auth_session.dart';
import 'package:fl_clash/auth/providers.dart';
import 'package:fl_clash/common/tdesign.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/starcore/models/plan.dart';
import 'package:fl_clash/starcore/models/user_info.dart';
import 'package:fl_clash/starcore/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/personal_center/personal_center.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  setUpAll(() {
    globalState.packageInfo = PackageInfo(
      appName: 'Silent',
      packageName: 'com.example.silent',
      version: '1.2.1',
      buildNumber: '1',
    );
  });

  testWidgets('shows account, current plan, orders and account actions', (
    tester,
  ) async {
    await _setSurface(tester);
    final controller = _authenticatedController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _TestScope(controller: controller, info: _userInfo()),
    );
    await tester.pumpAndSettle();

    expect(find.text('user@example.com'), findsOneWidget);
    expect(find.text('My plan'), findsOneWidget);
    expect(find.text('Yearly'), findsOneWidget);
    expect(find.text('365 days'), findsOneWidget);
    expect(find.text('1500G'), findsOneWidget);
    expect(find.text('1/3'), findsOneWidget);
    expect(find.text('50mbits/s'), findsOneWidget);
    expect(find.text('My orders'), findsOneWidget);
    expect(find.text('Pending payment'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Change password'), findsOneWidget);
    expect(find.text('App version'), findsOneWidget);
    expect(find.text('1.2.1'), findsOneWidget);
    expect(find.text('Log out'), findsOneWidget);
  });

  testWidgets('shows the no-plan state', (tester) async {
    await _setSurface(tester);
    final controller = _authenticatedController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _TestScope(controller: controller, info: _userInfo(withPlan: false)),
    );
    await tester.pumpAndSettle();

    expect(find.text('No active plan'), findsOneWidget);
  });

  for (final locale in const [
    Locale('zh', 'CN'),
    Locale('en'),
    Locale('ja'),
    Locale('ru'),
  ]) {
    testWidgets(
      'keeps the profile overflow-free for ${locale.toLanguageTag()}',
      (tester) async {
        await _setSurface(tester, size: const Size(320, 640));
        final controller = _authenticatedController();
        addTearDown(controller.dispose);
        await tester.pumpWidget(
          _TestScope(
            controller: controller,
            info: _userInfo(planName: 'International unlimited yearly plan'),
            locale: locale,
            textScaleFactor: 1.6,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(PersonalCenterView), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}

class _TestScope extends StatelessWidget {
  const _TestScope({
    required this.controller,
    required this.info,
    this.locale,
    this.textScaleFactor = 1,
  });

  final AuthController controller;
  final UserInfo info;
  final Locale? locale;
  final double textScaleFactor;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        authControllerProvider.overrideWithValue(controller),
        userInfoProvider.overrideWith((ref, uid) async => info),
      ],
      child: MaterialApp(
        theme: TDesignThemeData.build(brightness: Brightness.light),
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.delegate.supportedLocales,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScaleFactor)),
            child: child!,
          );
        },
        home: const PersonalCenterView(),
      ),
    );
  }
}

AuthController _authenticatedController() {
  final controller = AuthController();
  controller
    ..status = AuthStatus.authenticated
    ..session = AuthSession(
      uid: 'user-1',
      email: 'user@example.com',
      accessToken: 'access',
      refreshToken: 'refresh',
      accessExpireAt: DateTime.now().add(const Duration(hours: 1)),
      refreshExpireAt: DateTime.now().add(const Duration(days: 1)),
    );
  return controller;
}

UserInfo _userInfo({bool withPlan = true, String planName = 'Yearly'}) {
  final plan = Plan(
    id: 'yearly',
    name: planName,
    type: PlanType.time,
    durationDays: 365,
    trafficBytes: 1500 * 1024 * 1024 * 1024,
    speedLimitMbps: 50,
    maxDevices: 3,
    description: '',
    priceAmount: 2000,
    currency: 'USD',
  );
  return UserInfo(
    username: 'user@example.com',
    currentPlan: withPlan ? plan : null,
    remainingDays: 365,
    remainingTrafficBytes: 1500 * 1024 * 1024 * 1024,
    linkUrl: '',
    activeEntitlementType: withPlan ? 'time' : '',
    unlimited: false,
    boundDeviceCount: 1,
  );
}

Future<void> _setSurface(
  WidgetTester tester, {
  Size size = const Size(375, 812),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
