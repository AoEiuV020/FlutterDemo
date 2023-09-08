import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:isolate';
import 'dart:math' as math;

import 'debug.dart';

class AsyncDecoder {
  Stream<String> decode(Stream<List<int>> data) async* {
    var mainReceive = ReceivePort();
    await Isolate.spawn((SendPort sendPort) {
      final receivePort = ReceivePort();
      sendPort.send(receivePort.sendPort);
      final streamController = StreamController<List<int>>();
      streamController.stream
          .transform(const Utf8Decoder(allowMalformed: true))
          .transform(const StringConverter())
          .listen((event) {
        sendPort.send(event);
      });
      receivePort.listen((event) {
        streamController.sink.add(event);
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
      yield message as String;
    }
  }
}

class StringConverter extends Converter<String, String> {
  const StringConverter();

  @override
  String convert(String input) {
    log("${getIsolateName()}> convert");
    // unreachable,
    return input;
  }

  @override
  Sink<String> startChunkedConversion(Sink<String> sink) {
    log("${getIsolateName()}> startChunkedConversion");
    return StringSink(sink);
  }
}

class StringSink implements Sink<String> {
  StringSink(this.sink);

  final Sink<String> sink;

  @override
  void add(String data) {
    log("${getIsolateName()}> add: ${data.length}");
    const max = 1000;
    for (int i = 0; i < data.length; i += max) {
      sink.add(data.substring(i, math.min(i + max, data.length)));
    }
  }

  @override
  void close() {
    log("${getIsolateName()}> close");
    sink.close();
  }
}
