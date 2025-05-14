import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:isolate_manager/isolate_manager.dart';

import 'native_add_bindings_generated.dart';

/// A very short-lived native function.
///
/// For very short-lived functions, it is fine to call them on the main isolate.
/// They will block the Dart execution while running the native function, so
/// only do this for native functions which are guaranteed to be short-lived.
int sum(int a, int b) => _bindings.sum(a, b);

// 创建共享的isolate管理器
final _sharedIsolateManager = IsolateManager.createShared();

/// A longer lived native function
Future<int> sumAsync(int a, int b) async {
  return _sharedIsolateManager.compute(_sumLongRunning, [a, b]);
}

// HTTP API调用
Future<int> sumViaHttp(int a, int b) async {
  return _sharedIsolateManager.compute(_sumViaHttp, [a, b]);
}

// 长时间运行的计算worker函数
@isolateManagerSharedWorker
int _sumLongRunning(List<int> values) {
  return _bindings.sum_long_running(values[0], values[1]);
}

// HTTP调用worker函数
@isolateManagerSharedWorker
int _sumViaHttp(List<int> values) {
  final a = values[0];
  final b = values[1];
  final errorPointer = calloc<Pointer<Char>>();

  try {
    final result = _bindings.sum_via_http(a, b, errorPointer);

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

// 应用结束时停止isolate管理器
Future<void> disposeIsolates() async {
  await _sharedIsolateManager.stop();
}
