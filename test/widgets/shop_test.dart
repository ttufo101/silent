import 'package:fl_clash/common/tdesign.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/starcore/models/plan.dart';
import 'package:fl_clash/starcore/providers.dart';
import 'package:fl_clash/views/shop/shop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows time plans and switches to traffic plans', (tester) async {
    await _setSurface(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          plansProvider.overrideWith(
            (ref) async => [
              _plan(id: 'time', name: 'Yearly', type: PlanType.time),
              _plan(
                id: 'traffic',
                name: '1500 GB',
                type: PlanType.traffic,
                durationDays: 0,
                trafficBytes: 1500 * 1024 * 1024 * 1024,
              ),
            ],
          ),
        ],
        child: const _TestApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Plan'), findsOneWidget);
    expect(find.text('Yearly'), findsOneWidget);
    expect(find.text(r'$20.0'), findsOneWidget);
    expect(find.text('365 days'), findsOneWidget);
    expect(find.text('Buy now'), findsOneWidget);
    expect(
      find.ancestor(
        of: find.text('Buy now'),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is ButtonStyleButton ||
              widget is InkWell ||
              widget is GestureDetector,
        ),
      ),
      findsNothing,
    );

    await tester.tap(find.text('Traffic').first);
    await tester.pumpAndSettle();

    expect(find.text('Yearly'), findsNothing);
    expect(find.text('1500 GB'), findsOneWidget);
    expect(find.text('1500G'), findsOneWidget);
  });

  testWidgets('shows the empty state for the selected type', (tester) async {
    await _setSurface(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          plansProvider.overrideWith(
            (ref) async => [
              _plan(id: 'traffic', name: 'Traffic', type: PlanType.traffic),
            ],
          ),
        ],
        child: const _TestApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No plans available'), findsOneWidget);
  });

  testWidgets('shows a retry action when plans fail to load', (tester) async {
    await _setSurface(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          plansProvider.overrideWith(
            (ref) => Future<List<Plan>>.error(Exception('network')),
          ),
        ],
        child: const _TestApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Unable to load plans'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Retry'), findsOneWidget);
  });
}

Future<void> _setSurface(WidgetTester tester) async {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Plan _plan({
  required String id,
  required String name,
  required PlanType type,
  int durationDays = 365,
  int trafficBytes = 0,
}) {
  return Plan(
    id: id,
    name: name,
    type: type,
    durationDays: durationDays,
    trafficBytes: trafficBytes,
    speedLimitMbps: 50,
    maxDevices: 3,
    description: '',
    priceAmount: 2000,
    currency: 'USD',
  );
}

class _TestApp extends StatelessWidget {
  const _TestApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: TDesignThemeData.build(brightness: Brightness.light),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.delegate.supportedLocales,
      home: const ShopView(),
    );
  }
}
