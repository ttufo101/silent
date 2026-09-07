import 'package:fl_clash/auth/providers.dart';
import 'package:fl_clash/starcore/models/plan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final plansProvider = FutureProvider<List<Plan>>((ref) {
  return ref.watch(starcoreApiProvider).getPlans();
});
