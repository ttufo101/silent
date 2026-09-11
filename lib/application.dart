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
  bool _authenticatedStartupStarted = false;
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
    unawaited(_initializeAuth());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ref.read(appSettingProvider).silentLaunch) {
        window?.show();
      }
      if (mounted && _showSplash) {
        setState(() => _showSplash = false);
        startupTiming.mark('interactive shell requested');
      }
    });
  }

  Future<void> _initializeAuth() async {
    await _authController.initialize();
    startupTiming.mark('authentication restored');
    if (_authController.status != AuthStatus.authenticated && mounted) {
      setState(() => _showSplash = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        startupTiming.finish('login screen first frame');
      });
    }
  }

  void _handleAuthChanged() {
    if (_authController.status == AuthStatus.authenticated) {
      if (!_authenticatedStartupStarted) {
        _authenticatedStartupStarted = true;
        if (!startupTiming.isActive) {
          startupTiming.start();
        }
        startupTiming.mark('authenticated session ready');
      }
      ref.read(serverProfileSyncErrorProvider.notifier).set(null);
      unawaited(_prepareAndAttach());
    } else if (mounted) {
      _authenticatedStartupStarted = false;
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
    try {
      final hasCachedProfile = await _profileSync.prepare();
      startupTiming.mark(
        hasCachedProfile ? 'profile cache ready' : 'profile cache missing',
      );
      Future<ServerProfileSyncResult?>? synchronizationTask;
      if (!hasCachedProfile) {
        startupTiming.mark('profile synchronization requested');
        synchronizationTask = _synchronizeProfile(apply: false);
      }
      if (!_appAttached) {
        if (globalState.navigatorKey.currentContext == null) {
          exit(0);
        }
        startupTiming.mark('application attach requested');
        await globalState.attach(startCore: false);
        _appAttached = true;
        startupTiming.mark('application attach completed');
      }
      app?.initShortcuts();
      if (!mounted) return;
      setState(() => _showSplash = false);
      startupTiming.mark('home requested');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        startupTiming.mark('home first frame');
      });
      unawaited(
        _completeStartup(
          hasCachedProfile: hasCachedProfile,
          synchronizationTask: synchronizationTask,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _showSplash = false;
      });
      ref.read(serverProfileSyncErrorProvider.notifier).set(error.toString());
      WidgetsBinding.instance.addPostFrameCallback((_) {
        startupTiming.finish('home first frame with startup error');
      });
    }
  }

  Future<void> _completeStartup({
    required bool hasCachedProfile,
    required Future<ServerProfileSyncResult?>? synchronizationTask,
  }) async {
    try {
      var coreReady = false;
      if (hasCachedProfile) {
        try {
          await globalState.ensureCoreReady();
          coreReady = true;
          startupTiming.mark('core ready from cache');
        } catch (error) {
          commonPrint.log(error.toString(), logLevel: LogLevel.warning);
          startupTiming.mark('core preparation from cache failed');
        }
      }
      if (synchronizationTask == null) {
        startupTiming.mark('profile synchronization requested');
      }
      final synchronizationResult =
          await (synchronizationTask ?? _synchronizeProfile(apply: false));
      startupTiming.mark('profile synchronization completed');
      final hasSubscription =
          synchronizationResult?.hasSubscription ?? hasCachedProfile;
      if (hasSubscription) {
        if (!coreReady || synchronizationResult?.changed == true) {
          try {
            await _profileSync.applyCurrentProfile();
            startupTiming.mark('synchronized profile ready');
          } catch (error) {
            commonPrint.log(error.toString(), logLevel: LogLevel.warning);
            startupTiming.mark('synchronized profile preparation failed');
          }
        }
        _requestInitialVpnPermissionAfterFrame();
      }
      startupTiming.finish(
        synchronizationResult != null
            ? 'background startup complete'
            : 'background startup failed',
      );
    } catch (error) {
      commonPrint.log(error.toString(), logLevel: LogLevel.warning);
      ref.read(serverProfileSyncErrorProvider.notifier).set(error.toString());
      startupTiming.finish('background startup failed');
    }
  }

  Future<ServerProfileSyncResult?> _synchronizeProfile({
    required bool apply,
  }) async {
    try {
      final result = await _profileSync.synchronize(apply: apply);
      ref.read(serverProfileSyncErrorProvider.notifier).set(null);
      return result;
    } catch (error) {
      commonPrint.log(error.toString(), logLevel: LogLevel.warning);
      ref.read(serverProfileSyncErrorProvider.notifier).set(error.toString());
      return null;
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
          home: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: _showSplash
                ? const _SplashView(key: ValueKey('splash'))
                : _authController.status == AuthStatus.authenticated ||
                      (_authController.status == AuthStatus.initializing &&
                          ref.read(profilesProvider).isNotEmpty)
                ? KeyedSubtree(key: const ValueKey('home'), child: child!)
                : LoginView(
                    key: const ValueKey('login'),
                    controller: _authController,
                  ),
          ),
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
  const _SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: MediaQuery.platformBrightnessOf(context) == Brightness.dark
          ? const Color(0xFF101828)
          : const Color(0xFFF6F8FC),
      child: SafeArea(
        child: Center(
          child: Image.asset(
            'assets/images/icon.png',
            width: 96,
            height: 96,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
