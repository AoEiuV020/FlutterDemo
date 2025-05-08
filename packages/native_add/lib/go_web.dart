// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter, non_constant_identifier_names

import 'dart:js';
import 'dart:js_interop' as js_interop;
import 'package:js/js.dart';

@JS()
@staticInterop
class JSWindow {}

extension JSWindowExtension on JSWindow {
  external String Function(String input) get evalCommand;
  external int sum(int a, int b);
  external js_interop.JSPromise<js_interop.JSNumber> sum_long_running(int a, int b);
}

@JS()
class Go {
  external Go();
  external dynamic run(instance);
  external JsObject importObject();
}
