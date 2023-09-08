import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';

import 'debug.dart';
import 'decoder.dart';

/// Displays detailed information about a SampleItem.
class SampleItemDetailsView extends StatelessWidget {
  const SampleItemDetailsView(this.currentFile, {super.key});

  static const routeName = '/sample_item';

  final File currentFile;

  Future<String> getFuture() async {
    log("${getIsolateName()}> getFuture");
    try {
      return currentFile.readAsStringSync();
    } on FileSystemException catch (_) {
      return String.fromCharCodes(currentFile.readAsBytesSync());
    }
  }

  Stream<List<String>> getStream() async* {
    log("${getIsolateName()}> getStream");
    final decoder = AsyncDecoder();
    List<String> items = [];
    await for (String str in decoder.decode(currentFile.openRead())) {
      items.add(str);
      yield items;
    }
  }

  Future<List<String>> dataToString(List<int> data) async {
    log("${getIsolateName()}> dataToString, data.length=${data.length}");
    return Stream.fromIterable([String.fromCharCodes(data)])
        .transform(const StringConverter())
        .toList();
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
