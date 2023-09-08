import 'dart:async';
import 'dart:isolate';

class IsolateTransform<S, T> {
  Stream<T> transform(
      Stream<S> data, Stream<T> Function(Stream<S> e) mapper) async* {
    var mainReceive = ReceivePort();
    await Isolate.spawn((SendPort sendPort) {
      final receivePort = ReceivePort();
      sendPort.send(receivePort.sendPort);
      final streamController = StreamController<S>();
      mapper(streamController.stream).listen((event) {
        sendPort.send(event);
      });
      receivePort.listen((event) {
        streamController.sink.add(event as S);
      }, onDone: () {
        streamController.close();
      });
    }, mainReceive.sendPort);

    await for (var message in mainReceive) {
      if (message is SendPort) {
        data.listen((event) {
          message.send(event);
        });
        continue;
      }
      yield message as T;
    }
  }
}
