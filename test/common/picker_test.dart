import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:fl_clash/common/picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test/test.dart';

void main() {
  group('PlatformFileExt.readBytes', () {
    test('loads bytes from the picked file path', () async {
      final directory = await Directory.systemTemp.createTemp(
        'fl_clash_picker_test_',
      );
      addTearDown(() => directory.delete(recursive: true));

      final file = File('${directory.path}/profile.yaml');
      await file.writeAsString('mixed-port: 7890');

      final platformFile = _TestPlatformFile(file.path);

      final bytes = await platformFile.readBytes();

      expect(String.fromCharCodes(bytes), 'mixed-port: 7890');
    });
  });
}

base class _TestPlatformFile extends PlatformFile {
  final String filePath;

  _TestPlatformFile(this.filePath);

  @override
  String get name => File(filePath).uri.pathSegments.last;

  @override
  Uri get uri => Uri.file(filePath);

  @override
  XFile get xFile => XFile(filePath);

  @override
  Future<int> length() => File(filePath).length();

  @override
  Future<Uint8List> readAsBytes() => File(filePath).readAsBytes();

  @override
  Stream<Uint8List> readAsByteStream() =>
      File(filePath).openRead().map(Uint8List.fromList);
}
