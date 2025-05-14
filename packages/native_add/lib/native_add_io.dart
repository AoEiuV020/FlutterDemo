import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:convert';
import 'package:ffi/ffi.dart';

import 'native_add_bindings_generated.dart';

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
///
/// Modify this to suit your own use case. Example use cases:
///
/// 1. Reuse a single isolate for various different kinds of requests.
/// 2. Use multiple helper isolates for parallel execution.
Future<int> sumAsync(int a, int b) async {
  final SendPort helperIsolateSendPort = await _helperIsolateSendPort;
  final int requestId = _nextSumRequestId++;
  final _SumRequest request = _SumRequest(requestId, a, b);
  final Completer<int> completer = Completer<int>();
  _sumRequests[requestId] = completer;
  helperIsolateSendPort.send(request);
  return completer.future;
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

/// A request to compute `sum`.
///
/// Typically sent from one isolate to another.
class _SumRequest {
  final int id;
  final int a;
  final int b;

  const _SumRequest(this.id, this.a, this.b);
}

/// A response with the result of `sum`.
///
/// Typically sent from one isolate to another.
class _SumResponse {
  final int id;
  final int result;

  const _SumResponse(this.id, this.result);
}

/// Counter to identify [_SumRequest]s and [_SumResponse]s.
int _nextSumRequestId = 0;

/// Mapping from [_SumRequest] `id`s to the completers corresponding to the correct future of the pending request.
final Map<int, Completer<int>> _sumRequests = <int, Completer<int>>{};

/// The SendPort belonging to the helper isolate.
Future<SendPort> _helperIsolateSendPort = () async {
  // The helper isolate is going to send us back a SendPort, which we want to
  // wait for.
  final Completer<SendPort> completer = Completer<SendPort>();

  // Receive port on the main isolate to receive messages from the helper.
  // We receive two types of messages:
  // 1. A port to send messages on.
  // 2. Responses to requests we sent.
  final ReceivePort receivePort =
      ReceivePort()..listen((dynamic data) {
        if (data is SendPort) {
          // The helper isolate sent us the port on which we can sent it requests.
          completer.complete(data);
          return;
        }
        if (data is _SumResponse) {
          // The helper isolate sent us a response to a request we sent.
          final Completer<int> completer = _sumRequests[data.id]!;
          _sumRequests.remove(data.id);
          completer.complete(data.result);
          return;
        }
        throw UnsupportedError('Unsupported message type: ${data.runtimeType}');
      });

  // Start the helper isolate.
  await Isolate.spawn((SendPort sendPort) async {
    final ReceivePort helperReceivePort =
        ReceivePort()..listen((dynamic data) {
          // On the helper isolate listen to requests and respond to them.
          if (data is _SumRequest) {
            final int result = _bindings.sum_long_running(data.a, data.b);
            final _SumResponse response = _SumResponse(data.id, result);
            sendPort.send(response);
            return;
          }
          throw UnsupportedError(
            'Unsupported message type: ${data.runtimeType}',
          );
        });

    // Send the port to the main isolate on which we can receive requests.
    sendPort.send(helperReceivePort.sendPort);
  }, receivePort.sendPort);

  // Wait until the helper isolate has sent us back the SendPort on which we
  // can start sending requests.
  return completer.future;
}();
