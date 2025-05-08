// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'go_web.dart';
import 'dart:html' as html;

JSWindow get jsWindow => html.window as JSWindow;

int sum(int a, int b) => jsWindow.sum(a, b);

Future<int> sumAsync(int a, int b) async {
  return jsWindow.sum_long_running(a, b);
}
