import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/theme.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/hotkey.dart';
import 'package:fl_clash/views/routing_domain_rules.dart';
import 'package:fl_clash/views/views.dart';
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

  final cases = <String, Widget>{
    'dashboard': const DashboardView(),
    'proxies': const ProxiesView(),
    'requests': const RequestsView(),
    'resources': const ResourcesView(),
    'logs': const LogsView(),
    'tools': const ToolsView(),
    'backup and restore': const BackupAndRestore(),
    'hotkeys': const HotKeyView(),
    'access control': const AccessView(),
  };

  for (final entry in cases.entries) {
    testWidgets('${entry.key} renders its default state', (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer(
        overrides: [profilesProvider.overrideWith(_TestProfiles.new)],
      );
      addTearDown(container.dispose);
      globalState.container = container;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _TestApp(child: entry.value),
        ),
      );
      await tester.pump();
      if (entry.key == 'access control') {
        await tester.pump(const Duration(milliseconds: 301));
      }
      final scrollables = find.byType(Scrollable);
      if (scrollables.evaluate().isNotEmpty) {
        for (var index = 0; index < 8; index++) {
          await tester.drag(scrollables.first, const Offset(0, -700));
          await tester.pump();
        }
      }

      expect(find.byWidget(entry.value), findsOneWidget);
      expect(tester.takeException(), null);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  const toolDestinations = <({String category, String title, Type view})>[
    (
      category: 'Proxy rules',
      title: 'Custom proxy domains',
      view: RoutingDomainRulesView,
    ),
    (category: 'Other', title: 'Feedback', view: FeedbackView),
  ];

  for (final destination in toolDestinations) {
    testWidgets('tools opens ${destination.title}', (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer(
        overrides: [profilesProvider.overrideWith(_TestProfiles.new)],
      );
      addTearDown(container.dispose);
      globalState.container = container;
      container
          .read(viewSizeProvider.notifier)
          .update((_) => const Size(1400, 1000));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const _TestApp(child: ToolsView()),
        ),
      );
      await tester.pump();

      await tester.tap(find.text(destination.category));
      await tester.pumpAndSettle();

      final target = find.text(destination.title);
      await tester.scrollUntilVisible(
        target,
        500,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(target);
      await tester.pumpAndSettle();

      expect(find.byType(destination.view), findsOneWidget);
      expect(tester.takeException(), null);
    });
  }
}

class _TestProfiles extends Profiles {
  final List<Profile> initial;

  _TestProfiles([this.initial = const []]);

  @override
  List<Profile> build() => initial;
}

class _TestApp extends StatelessWidget {
  final Widget child;

  const _TestApp({required this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: globalState.navigatorKey,
      theme: TDesignThemeData.build(
        brightness: Brightness.light,
        viewMode: ViewMode.desktop,
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.delegate.supportedLocales,
      builder: (context, child) {
        globalState.measure = Measure.of(context, 1);
        globalState.theme = CommonTheme.of(context, 1);
        return child!;
      },
      home: child,
    );
  }
}
