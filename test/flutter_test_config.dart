import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the bundled Inter font so text is measured with real glyph widths.
/// Without it tests fall back to the square "Ahem" font, which is much wider
/// and triggers overflows that never happen on a device.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final font = File('assets/fonts/Inter.ttf').readAsBytesSync();
  final loader = FontLoader('Inter')
    ..addFont(Future.value(ByteData.sublistView(font)));
  await loader.load();
  await testMain();
}
