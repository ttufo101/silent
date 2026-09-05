import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fl_clash/auth/auth_controller.dart';
import 'package:fl_clash/auth/providers.dart';
import 'package:fl_clash/auth/views/login.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/manager/hotkey_manager.dart';
import 'package:fl_clash/manager/manager.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/starcore/server_profile_sync.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pages/pages.dart';

class Application extends ConsumerStatefulWidget {
  const Application({super.key});

  @override
  ConsumerState<Application> createState() => ApplicationState();
}

class ApplicationState extends ConsumerState<Application> {
  late final AuthController _authController;
  late final ServerProfileSync _profileSync;
  bool _showSplash = true;
  bool _appAttached = false;
  Future<void>? _attachTask;

  final _pageTransitionsTheme = const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: commonSharedXPageTransitions,
      TargetPlatform.windows: commonSharedXPageTransitions,
      TargetPlatform.linux: commonSharedXPageTransitions,
      TargetPlatform.macOS: commonSharedXPageTransitions,
    },
  );

  ThemeData _getAppTheme({required Brightness brightness}) {
    return TDesignThemeData.build(
      brightness: brightness,
    ).copyWith(pageTransitionsTheme: _pageTransitionsTheme);
  }

  @override
  void initState() {
    super.initState();
    _authController = ref.read(authControllerProvider)
      ..addListener(_handleAuthChanged);
    _profileSync = ref.read(serverProfileSyncProvider);
    SystemNavigator.setFrameworkHandlesBack(true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeAuth());
  }

  Future<void> _initializeAuth() async {
    await _authController.initialize();
    if (_authController.status != AuthStatus.authenticated && mounted) {
      setState(() => _showSplash = false);
    }
  }

  void _handleAuthChanged() {
    if (_authController.status == AuthStatus.authenticated) {
      unawaited(_prepareAndAttach());
    } else if (mounted) {
      _profileSync.invalidate();
      if (_appAttached) {
        unawaited(ref.read(setupActionProvider.notifier).setRunning(false));
      }
      setState(() {
        _showSplash = false;
      });
    }
  }

  Future<void> _prepareAndAttach() {
    final existing = _attachTask;
    if (existing != null) return existing;
    final task = _runPrepareAndAttach();
    _attachTask = task;
    unawaited(
      task.then(
        (_) => _clearAttachTask(task),
        onError: (Object _, StackTrace _) => _clearAttachTask(task),
      ),
    );
    return task;
  }

  void _clearAttachTask(Future<void> task) {
    if (identical(_attachTask, task)) {
      _attachTask = null;
    }
  }

  Future<void> _runPrepareAndAttach() async {
    if (mounted) {
      setState(() {
        _showSplash = true;
      });
    }
    try {
      await _profileSync.prepare();
      if (!_appAttached) {
        if (globalState.navigatorKey.currentContext == null) {
          exit(0);
        }
        await globalState.attach();
        _appAttached = true;
        _requestInitialVpnPermissionAfterFrame();
      } else {
        await ref
            .read(setupActionProvider.notifier)
            .applyProfile(force: true, silence: true);
      }
      app?.initShortcuts();
      if (!mounted) return;
      setState(() => _showSplash = false);
      unawaited(_synchronizeProfile());
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _showSplash = false;
      });
      ref.read(serverProfileSyncErrorProvider.notifier).set(error.toString());
    }
  }

  Future<void> _synchronizeProfile() async {
    try {
      await _profileSync.synchronize();
      ref.read(serverProfileSyncErrorProvider.notifier).set(null);
    } catch (error) {
      commonPrint.log(error.toString(), logLevel: LogLevel.warning);
      ref.read(serverProfileSyncErrorProvider.notifier).set(error.toString());
    }
  }

  void _requestInitialVpnPermissionAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestInitialVpnPermission();
    });
  }

  Future<void> _requestInitialVpnPermission() async {
    if (!system.isAndroid || await preferences.hasRequestedVpnPermission) {
      return;
    }
    await preferences.markVpnPermissionRequested();
    await app?.requestVpnPermission();
  }

  Widget _buildPlatformState({required Widget child}) {
    if (system.isDesktop) {
      return WindowManager(
        child: TrayManager(
          child: HotKeyManager(child: ProxyManager(child: child)),
        ),
      );
    }
    return AndroidManager(child: TileManager(child: child));
  }

  Widget _buildState({required Widget child}) {
    return AppStateManager(
      child: CoreManager(
        child: ConnectivityManager(
          onConnectivityChanged: (results) async {
            commonPrint.log('connectivityChanged ${results.toString()}');
            ref.read(systemActionProvider.notifier).updateLocalIp();
            if (results.any((result) => result != ConnectivityResult.none)) {
              _profileSync.scheduleNetworkRecovery();
            }
          },
          child: child,
        ),
      ),
    );
  }

  Widget _buildPlatformApp({required Widget child}) {
    if (system.isDesktop) {
      return WindowHeaderContainer(child: child);
    }
    return VpnManager(child: child);
  }

  Widget _buildApp({required Widget child}) {
    return StatusManager(child: ThemeManager(child: child));
  }

  @override
  Widget build(context) {
    return Consumer(
      builder: (_, ref, child) {
        final locale = ref.watch(
          appSettingProvider.select((state) => state.locale),
        );
        final themeMode = ref.watch(
          appSettingProvider.select((state) => state.themeMode),
        );
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: globalState.navigatorKey,
          onNavigationNotification: (_) => true,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          builder: (_, child) {
            return _buildApp(
              child: _buildPlatformState(
                child: _buildState(child: _buildPlatformApp(child: child!)),
              ),
            );
          },
          scrollBehavior: BaseScrollBehavior(),
          title: appName,
          locale: utils.getLocaleForString(locale),
          supportedLocales: AppLocalizations.delegate.supportedLocales,
          themeMode: themeMode,
          theme: _getAppTheme(brightness: Brightness.light),
          darkTheme: _getAppTheme(brightness: Brightness.dark),
          home: _showSplash
              ? const _SplashView()
              : _authController.status == AuthStatus.authenticated
              ? child!
              : LoginView(controller: _authController),
        );
      },
      child: const HomePage(),
    );
  }

  @override
  void dispose() {
    _authController.removeListener(_handleAuthChanged);
    super.dispose();
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF4F6FF),
      child: SafeArea(
        child: Center(
          child: Image.asset(
            'assets/images/start.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
