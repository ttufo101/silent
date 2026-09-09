import 'dart:convert';
import 'dart:typed_data';

import 'package:fl_clash/auth/data/gateway_client.dart';
import 'package:fl_clash/starcore/models/plan.dart';
import 'package:fl_clash/starcore/models/user_info.dart';

class ServerLinks {
  const ServerLinks({required this.hasSubscription, this.content});

  final bool hasSubscription;
  final Uint8List? content;
}

class StarcoreApi {
  StarcoreApi(this._client);

  static const _module = 'starland.starcore.com';
  final GatewayClient _client;

  Future<List<Plan>> getPlans() async {
    final data = await _client.call(
      module: _module,
      method: 'GetPlans',
      params: const {},
    );
    final plans = data['plans'];
    if (plans is! List) {
      throw const GatewayException('Invalid GetPlansResponse.plans');
    }
    try {
      return plans
          .map((plan) => Plan.fromJson(Map<String, dynamic>.from(plan as Map)))
          .toList(growable: false);
    } on Object {
      throw const GatewayException('Invalid GetPlansResponse.plans');
    }
  }

  Future<UserInfo> getUserInfo() async {
    final data = await _client.call(
      module: _module,
      method: 'GetUserInfo',
      params: const {},
    );
    try {
      return UserInfo.fromJson(data);
    } on Object {
      throw const GatewayException('Invalid GetUserInfoResponse');
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final data = await _client.call(
      module: _module,
      method: 'ChangePassword',
      params: {'old_password': oldPassword, 'new_password': newPassword},
    );
    if (data['success'] is! bool) {
      throw const GatewayException('Invalid ChangePasswordResponse.success');
    }
    if (data['success'] != true) {
      throw const GatewayException('Password change failed');
    }
  }

  Future<ServerLinks> getLinks() async {
    final data = await _client.call(
      module: _module,
      method: 'GetLinks',
      params: const {},
      requestTimeout: const Duration(seconds: 10),
    );
    final subscriptionValue = data.containsKey('has_subscription')
        ? data['has_subscription']
        : data['hasSubscription'];
    final content = data['content'];
    final hasSubscription = switch (subscriptionValue) {
      final bool value => value,
      null => content is String && content.isNotEmpty,
      _ => throw const GatewayException(
        'Invalid GetLinksResponse.has_subscription',
      ),
    };
    if (!hasSubscription) {
      return const ServerLinks(hasSubscription: false);
    }
    if (content is! String || content.isEmpty) {
      throw const GatewayException('Invalid GetLinksResponse.content');
    }
    try {
      final bytes = base64Decode(content);
      if (bytes.isEmpty) {
        throw const GatewayException('Empty proxy configuration');
      }
      return ServerLinks(hasSubscription: true, content: bytes);
    } on FormatException {
      throw const GatewayException('Invalid proxy configuration encoding');
    }
  }
}
