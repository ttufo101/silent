import 'dart:convert';
import 'dart:typed_data';

import 'package:fl_clash/auth/data/gateway_client.dart';

class StarcoreApi {
  StarcoreApi(this._client);

  static const _module = 'starland.starcore.com';
  final GatewayClient _client;

  Future<Uint8List> getLinks() async {
    final data = await _client.call(
      module: _module,
      method: 'GetLinks',
      params: const {},
    );
    final content = data['content'];
    if (content is! String || content.isEmpty) {
      throw const GatewayException('Invalid GetLinksResponse.content');
    }
    try {
      final bytes = base64Decode(content);
      if (bytes.isEmpty) {
        throw const GatewayException('Empty proxy configuration');
      }
      return bytes;
    } on FormatException {
      throw const GatewayException('Invalid proxy configuration encoding');
    }
  }
}
