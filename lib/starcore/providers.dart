import 'package:fl_clash/auth/providers.dart';
import 'package:fl_clash/common/print.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/starcore/models/plan.dart';
import 'package:fl_clash/starcore/models/user_info.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final plansProvider = FutureProvider<List<Plan>>((ref) {
  return ref.watch(starcoreApiProvider).getPlans();
});

final userInfoProvider = FutureProvider.family<UserInfo, String>((
  ref,
  _,
) async {
  final stopwatch = Stopwatch()..start();
  final authController = ref.read(authControllerProvider);
  final api = ref.read(starcoreApiProvider);
  try {
    await authController.ensureValidAccessToken();
    final info = await api.getUserInfo();
    commonPrint.log(
      'GetUserInfo completed in ${stopwatch.elapsedMilliseconds}ms',
    );
    return info;
  } catch (error, stackTrace) {
    commonPrint.log(
      'GetUserInfo failed after ${stopwatch.elapsedMilliseconds}ms: $error',
      logLevel: LogLevel.warning,
    );
    Error.throwWithStackTrace(error, stackTrace);
  }
}, retry: (_, _) => null);
