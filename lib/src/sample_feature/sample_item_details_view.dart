import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Displays detailed information about a SampleItem.
class SampleItemDetailsView extends StatelessWidget {
  SampleItemDetailsView(this.currentFile, {super.key});

  static const routeName = '/sample_item';

  final File currentFile;

  Future<String> getFuture() async {
    log("${Isolate.current.debugName}> getFuture");
    try {
      return currentFile.readAsStringSync();
    } on FileSystemException catch (_) {
      return String.fromCharCodes(currentFile.readAsBytesSync());
    }
  }

  Stream<String> getStream() {
    log("${Isolate.current.debugName}> getStream");
    return currentFile.openRead().asyncMap((event) async {
      log("${Isolate.current.debugName}> asyncMap add: ${event.length}");
      var ret = previous + event;
      previous = ret;
      return ret;
    }).asyncMap((event) async {
      log("${Isolate.current.debugName}> asyncMap dataToString: ${event.length}");
      return compute(dataToString, event);
    });
  }

  List<int> previous = [];

  String dataToString(List<int> data) {
    log("${Isolate.current.debugName}> dataToString, data.length=${data.length}");
    return String.fromCharCodes(data);
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
              log("${Isolate.current.debugName}> snapshot: ${snapshot.requireData.length}");
              return SingleChildScrollView(
                child: Text(snapshot.requireData),
              );
            }),
      ),
    );
  }
}

class StringConverter extends Converter<List<int>, String> {
  const StringConverter();

  @override
  String convert(List<int> input) {
    log("${Isolate.current.debugName}> convert");
    return String.fromCharCodes(input);
  }

  @override
  Sink<List<int>> startChunkedConversion(Sink<String> sink) {
    log("${Isolate.current.debugName}> startChunkedConversion");
    return StringSink(sink);
  }
}

class StringSink extends Sink<List<int>> {
  StringSink(this.sink);

  final Sink<String> sink;

  @override
  void add(List<int> data) {
    log("${Isolate.current.debugName}> add: ${data.length}");
    sink.add(String.fromCharCodes(data));
  }

  @override
  void close() {
    log("${Isolate.current.debugName}> close");
    sink.close();
  }
}
