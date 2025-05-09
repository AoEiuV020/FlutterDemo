// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:js_interop';

import 'go_web.dart';
import 'dart:html' as html;

JSWindow get jsWindow => html.window as JSWindow;

int sum(int a, int b) => jsWindow.sum(a, b);

Future<int> sumAsync(int a, int b) async {
  final result = await jsWindow.sum_long_running(a, b).toDart;
  return result.toDartInt;
}

String sumString(String a, String b) {
  return jsWindow.sum_string(a, b).toDart;
}
