import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Displays detailed information about a SampleItem.
class SampleItemDetailsView extends StatelessWidget {
  const SampleItemDetailsView(this.currentFile, {super.key});

  static const routeName = '/sample_item';

  final File currentFile;

  Stream<T> flattenStreams<T>(Stream<Stream<T>> source) async* {
    await for (var stream in source) {
      yield* stream;
    }
  }

  Future<String> getFuture() async {
    log("${Isolate.current.debugName}> getFuture");
    try {
      return currentFile.readAsStringSync();
    } on FileSystemException catch (_) {
      return String.fromCharCodes(currentFile.readAsBytesSync());
    }
  }

  Stream<List<String>> getStream() {
    log("${Isolate.current.debugName}> getStream");
    List<String> items = [];
    return flattenStreams(currentFile.openRead().asyncMap((event) async {
      log("${Isolate.current.debugName}> asyncMap dataToString: ${event
          .length}");
      var str = await compute(dataToString, event);
      return str;
    })).map((event) {
      items.add(event);
      return items;
    });
  }

  Stream<String> dataToString(List<int> data) {
    log("${Isolate.current.debugName}> dataToString, data.length=${data
        .length}");
    return Stream.fromIterable([String.fromCharCodes(data)])
        .transform(const StringConverter());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentFile.path),
      ),
      body: Center(
        child: StreamBuilder(
            stream: getStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              if (!snapshot.hasData) {
                return Text("loading ${currentFile.path}");
              }
              var data = snapshot.requireData;
              log("${Isolate.current.debugName}> data: ${data.length}");
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) =>
                    ListTile(
                        title: Text(data[index]),
                        leading: const CircleAvatar(
                          foregroundImage:
                          AssetImage('assets/images/flutter_logo.png'),
                        ),
                        onTap: () {
                          log("onTap");
                        }),
              );
            }),
      ),
    );
  }
}

class StringConverter extends Converter<String, String> {
  const StringConverter();

  @override
  String convert(String input) {
    log("${Isolate.current.debugName}> convert");
    // unreachable,
    return input;
  }

  @override
  Sink<String> startChunkedConversion(Sink<String> sink) {
    log("${Isolate.current.debugName}> startChunkedConversion");
    return StringSink(sink);
  }
}

class StringSink extends Sink<String> {
  StringSink(this.sink);

  final Sink<String> sink;

  @override
  void add(String data) {
    log("${Isolate.current.debugName}> add: ${data.length}");
    const max = 1000;
    for (int i = 0; i < data.length; i += max) {
      sink.add(data.substring(i, math.min(i + max, data.length)));
    }
  }

  @override
  void close() {
    log("${Isolate.current.debugName}> close");
    sink.close();
  }
}
