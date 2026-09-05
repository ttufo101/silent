import 'package:fl_clash/auth/auth_controller.dart';
import 'package:fl_clash/auth/data/gateway_client.dart';
import 'package:fl_clash/starcore/data/starcore_api.dart';
import 'package:fl_clash/starcore/server_profile_sync.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final gatewayClientProvider = Provider<GatewayClient>((ref) {
  return GatewayClient();
});

final authControllerProvider = Provider<AuthController>((ref) {
  final controller = AuthController(client: ref.read(gatewayClientProvider));
  ref.onDispose(controller.dispose);
  return controller;
});

final starcoreApiProvider = Provider<StarcoreApi>((ref) {
  return StarcoreApi(ref.read(gatewayClientProvider));
});

final serverProfileSyncProvider = Provider<ServerProfileSync>((ref) {
  final sync = ServerProfileSync(
    authController: ref.read(authControllerProvider),
    api: ref.read(starcoreApiProvider),
    ref: ref,
  );
  ref.onDispose(sync.dispose);
  return sync;
});
