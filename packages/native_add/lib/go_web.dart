// ignore_for_file: non_constant_identifier_names

import 'dart:js_interop';

@JS()
@staticInterop
class JSWindow {}

extension JSWindowExtension on JSWindow {
  external int sum(int a, int b);
  external JSPromise<JSNumber> sum_long_running(int a, int b);
  external String sum_string(String a, String b);
}
