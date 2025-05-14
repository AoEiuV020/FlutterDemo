import 'dart:async';
import 'dart:isolate';

/// 用于简化 Isolate 操作的辅助类
class IsolateHelper<T, R> {
  final Function _function;
  SendPort? _sendPort;
  ReceivePort? _receivePort;
  Isolate? _isolate;
  final Map<int, Completer<R>> _requests = {};
  int _nextRequestId = 0;

  /// 构造函数接收一个在 Isolate 中执行的函数
  IsolateHelper(this._function);

  /// 启动 Isolate
  Future<void> _initialize() async {
    if (_sendPort != null) return;

    final completer = Completer<SendPort>();
    _receivePort = ReceivePort();

    _receivePort!.listen((message) {
      if (message is SendPort) {
        completer.complete(message);
      } else if (message is _IsolateResponse) {
        final completer = _requests[message.id];
        if (completer != null) {
          _requests.remove(message.id);

          if (message.error != null) {
            // 如果有异常，则用异常完成 Future
            completer.completeError(
              message.error!,
              message.stackTrace != null
                  ? StackTrace.fromString(message.stackTrace!)
                  : null,
            );
          } else {
            // 否则用结果完成 Future
            completer.complete(message.result as R);
          }
        }
      }
    });

    _isolate = await Isolate.spawn(
      _isolateHandler,
      _HelperSetup(_receivePort!.sendPort, _function),
    );

    _sendPort = await completer.future;
  }

  /// 在 Isolate 中执行任务并返回结果
  Future<R> execute(T input) async {
    await _initialize();

    final requestId = _nextRequestId++;
    final completer = Completer<R>();
    _requests[requestId] = completer;

    _sendPort!.send(_IsolateRequest(requestId, input));

    return completer.future;
  }

  /// 释放资源
  void dispose() {
    _isolate?.kill();
    _receivePort?.close();
    _isolate = null;
    _receivePort = null;
    _sendPort = null;
    _requests.clear();
  }

  /// 在新的 Isolate 中运行的处理器
  static void _isolateHandler(_HelperSetup setup) {
    final receivePort = ReceivePort();

    receivePort.listen((message) {
      if (message is _IsolateRequest) {
        try {
          // 尝试调用函数并获取结果
          final result = setup.function.call(message.input);
          setup.sendPort.send(_IsolateResponse(message.id, result: result));
        } catch (e, stackTrace) {
          // 捕获异常，并发送回主 Isolate
          setup.sendPort.send(
            _IsolateResponse(
              message.id,
              error: e.toString(),
              stackTrace: stackTrace.toString(),
            ),
          );
        }
      }
    });

    setup.sendPort.send(receivePort.sendPort);
  }
}

/// Isolate 初始化配置
class _HelperSetup {
  final SendPort sendPort;
  final Function function;

  _HelperSetup(this.sendPort, this.function);
}

/// Isolate 请求
class _IsolateRequest<T> {
  final int id;
  final T input;

  _IsolateRequest(this.id, this.input);
}

/// Isolate 响应
class _IsolateResponse<R> {
  final int id;
  final R? result;
  final String? error;
  final String? stackTrace;

  _IsolateResponse(this.id, {this.result, this.error, this.stackTrace});
}
