import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';

/// Displays detailed information about a SampleItem.
class SampleItemDetailsView extends StatelessWidget {
  const SampleItemDetailsView(this.currentFile, {super.key});

  static const routeName = '/sample_item';

  final File currentFile;

  Future<String> getFuture() async {
    try {
      return currentFile.readAsStringSync();
    } on FileSystemException catch (_) {
      return String.fromCharCodes(currentFile.readAsBytesSync());
    }
  }

  Stream<String> getStream() {
    log("getStream");
    return currentFile.openRead().transform(const StringConverter());
  }

  @override
  Widget build(BuildContext context) {
    var sb = StringBuffer();
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
              log("snapshot: ${snapshot.requireData.length}");
              sb.write(snapshot.requireData);
              log("sb: ${sb.length}");
              return SingleChildScrollView(
                child: Text(sb.toString()),
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
    log("convert");
    return String.fromCharCodes(input);
  }

  @override
  Sink<List<int>> startChunkedConversion(Sink<String> sink) {
    log("startChunkedConversion");
    return StringSink(sink);
  }
}

class StringSink extends Sink<List<int>> {
  StringSink(this.sink);

  final Sink<String> sink;

  @override
  void add(List<int> data) {
    log("add: ${data.length}");
    sink.add(String.fromCharCodes(data));
  }

  @override
  void close() {
    log("close");
    sink.close();
  }
}
