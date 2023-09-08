import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:demo/src/sample_feature/debug.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FilePickerItemDetailsView extends StatelessWidget {
  const FilePickerItemDetailsView(this.currentFile, {super.key});

  static const routeName = '/file_picker_item';

  final PlatformFile currentFile;

  Stream<T> flattenStreams<T>(Stream<Stream<T>> source) async* {
    await for (var stream in source) {
      yield* stream;
    }
  }

  Stream<List<String>> getStream() {
    log("${getIsolateName()}> getStream");
    List<String> items = [];
    return flattenStreams(currentFile.readStream!.asyncMap((event) async {
      log("${getIsolateName()}> asyncMap dataToString: ${event.length}");
      return Stream.fromIterable(await compute(dataToString, event));
    })).map((event) {
      items.add(event);
      log("${getIsolateName()}> map add items: ${items.length}");
      return items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentFile.name),
      ),
      body: Center(
        child: StreamBuilder(
            stream: getStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              if (!snapshot.hasData) {
                return Text("loading ${currentFile.name}");
              }
              var data = snapshot.requireData;
              log("${getIsolateName()}> data: ${data.length}");
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) => ListTile(
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

Future<List<String>> dataToString(List<int> data) async {
  log("${getIsolateName()}> dataToString, data.length=${data.length}");
  return Stream.fromIterable([String.fromCharCodes(data)])
      .transform(const StringConverter())
      .toList();
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
