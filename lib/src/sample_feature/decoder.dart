import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:demo/src/sample_feature/isolate_transform.dart';

import 'debug.dart';

class AsyncDecoder {
  Stream<String> decode(Stream<List<int>> data) {
    return IsolateTransform<List<int>, String>().transform(
        data,
        (e) => e
            .transform(const Utf8Decoder(allowMalformed: true))
            .transform(const StringConverter()));
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
