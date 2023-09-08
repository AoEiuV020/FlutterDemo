import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:isolate/isolate.dart';

import 'debug.dart';

class AsyncDecoder {
  late Future<LoadBalancer> loadBalancer =
      LoadBalancer.create(1, IsolateRunner.spawn);

  Stream<String> decode(Stream<List<int>> data) async* {
    final lb = await loadBalancer;
    await for (var block in data) {
      yield* Stream.fromIterable(await lb.run(_dataToString, block));
    }
  }
}

Future<List<String>> _dataToString(List<int> data) async {
  log("${getIsolateName()}> dataToString, data.length=${data.length}");
  return Stream.fromIterable([String.fromCharCodes(data)])
      .transform(const StringConverter())
      .toList();
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
