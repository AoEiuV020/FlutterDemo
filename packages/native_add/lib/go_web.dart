// ignore_for_file: non_constant_identifier_names

import 'dart:js_interop';

@JS()
@staticInterop
class JSWindow {}

extension JSWindowExtension on JSWindow {
  external int sum(int a, int b);
  external JSPromise<JSNumber> sum_long_running(int a, int b);
  external String sum_string(String a, String b);
  external JSPromise<JSNumber> sum_via_http(int a, int b);
  external int increase();

  /// 通用调用接口，根据方法名和JSON参数字符串调用对应的Go函数
  /// 同步版本，直接返回结果
  external String go_call(String method, String paramJSON);

  /// 通用调用接口，根据方法名和JSON参数字符串调用对应的Go函数
  /// 异步版本，返回JavaScript Promise
  external JSPromise<JSString> go_call_async(String method, String paramJSON);
}
