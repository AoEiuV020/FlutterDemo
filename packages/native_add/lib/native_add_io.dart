import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

import 'native_add_bindings_generated.dart';
import 'isolate_helper.dart';

/// A very short-lived native function.
///
/// For very short-lived functions, it is fine to call them on the main isolate.
/// They will block the Dart execution while running the native function, so
/// only do this for native functions which are guaranteed to be short-lived.
int sum(int a, int b) => _bindings.sum(a, b);

/// A longer lived native function, which occupies the thread calling it.
///
/// Do not call these kind of native functions in the main isolate. They will
/// block Dart execution. This will cause dropped frames in Flutter applications.
/// Instead, call these native functions on a separate isolate.
Future<int> sumAsync(int a, int b) async {
  // 使用 IsolateHelper 执行长时间运行的计算
  return _sumIsolateHelper.execute(_SumParams(a, b));
}

// 创建一个专门用于处理sum_long_running的IsolateHelper实例
final _sumIsolateHelper = IsolateHelper<_SumParams, int>((params) {
  return _bindings.sum_long_running(params.a, params.b);
});

// 参数类
class _SumParams {
  final int a;
  final int b;

  _SumParams(this.a, this.b);
}

// String addition function
String sumString(String a, String b) {
  // 1. 将 Dart 字符串转换为 C 字符串 (Pointer<Utf8>)
  // Pointer<Utf8> 和 Pointer<Char> 都是 Pointer<Int8> 的别名或子类，
  // 所以它们在底层是兼容的，但 Pointer<Utf8> 提供了方便的 .toDartString() 方法。
  final Pointer<Utf8> cStringA = a.toNativeUtf8();
  final Pointer<Utf8> cStringB = b.toNativeUtf8();

  Pointer<Char> cResult = nullptr;

  try {
    // 2. 调用 Go 函数
    // 因为函数签名需要 Pointer<Char>，我们需要进行类型转换 (cast)
    // 这在底层是安全的，因为它们都是指向字节序列的指针。
    cResult = _bindings.sum_string(
      cStringA.cast<Char>(),
      cStringB.cast<Char>(),
    );

    if (cResult == nullptr) {
      throw Exception("Go function returned a null pointer!");
    }
    // 3. 将返回的 C 字符串 (Pointer<Char>) 转换回 Dart 字符串
    // 我们再次将其转换为 Pointer<Utf8> 以使用 .toDartString() 扩展方法。
    return cResult.cast<Utf8>().toDartString();
  } finally {
    // 4. 释放输入参数的内存 (由 toNativeUtf8 分配)
    calloc.free(cStringA);
    calloc.free(cStringB);

    // 5. 释放 Go 函数返回的字符串的内存 (通过我们导出的 free_string 函数)
    // 只有当 cResult 不是 nullptr 时才释放
    if (cResult != nullptr) {
      _bindings.free_string(cResult);
    }
  }
}

// HTTP API调用
Future<int> sumViaHttp(int a, int b) async {
  try {
    // 使用 IsolateHelper 执行 HTTP 请求
    return await _httpIsolateHelper.execute(_HttpParams(a, b));
  } catch (e) {
    // 现在我们能正确捕获并处理来自 Isolate 的异常
    print('在主 Isolate 中捕获到 HTTP 调用异常: $e');
    rethrow; // 重新抛出异常，或者进行其他处理
  }
}

// HTTP参数类
class _HttpParams {
  final int a;
  final int b;

  _HttpParams(this.a, this.b);
}

// 创建一个专门用于处理HTTP请求的IsolateHelper实例
final _httpIsolateHelper = IsolateHelper<_HttpParams, int>((params) {
  final errorPointer = calloc<Pointer<Char>>();

  try {
    final result = _bindings.sum_via_http(params.a, params.b, errorPointer);

    // 检查错误
    final errorMessagePtr = errorPointer.value;
    if (errorMessagePtr != nullptr) {
      try {
        final errorMessage = errorMessagePtr.cast<Utf8>().toDartString();
        throw Exception('HTTP调用失败: $errorMessage');
      } finally {
        _bindings.free_error_message(errorMessagePtr);
      }
    }

    return result;
  } finally {
    calloc.free(errorPointer);
  }
});

const String _libName = 'native_add';

/// The dynamic library in which the symbols for [NativeAddBindings] can be found.
final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open('$_libName.framework/$_libName');
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('lib$_libName.so');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

/// The bindings to the native functions in [_dylib].
final NativeAddBindings _bindings = NativeAddBindings(_dylib);

// 删除旧的 Isolate 实现代码...
// 注意：这里移除了原来的 _SumRequest, _SumResponse 类以及相关的全局变量和 _helperIsolateSendPort 函数
