import 'package:fl_clash/auth/providers.dart';
import 'package:fl_clash/common/print.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/starcore/models/plan.dart';
import 'package:fl_clash/starcore/models/user_info.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final plansProvider = FutureProvider<List<Plan>>((ref) {
  return ref.watch(starcoreApiProvider).getPlans();
});

final userInfoProvider = FutureProvider.autoDispose.family<UserInfo, String>((
  ref,
  _,
) async {
  try {
    await ref.read(authControllerProvider).ensureValidAccessToken();
    return await ref.read(starcoreApiProvider).getUserInfo();
  } catch (error, stackTrace) {
    commonPrint.log('GetUserInfo failed: $error', logLevel: LogLevel.warning);
    Error.throwWithStackTrace(error, stackTrace);
  }
}, retry: (_, _) => null);
