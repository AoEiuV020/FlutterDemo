import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'debug.dart';
import 'decoder.dart';

class FilePickerItemDetailsView extends StatelessWidget {
  const FilePickerItemDetailsView(this.currentFile, {super.key});

  static const routeName = '/file_picker_item';

  final PlatformFile currentFile;

  Stream<List<String>> getStream() async* {
    log("${getIsolateName()}> getStream");
    final decoder = AsyncDecoder();
    List<String> items = [];
    await for (String str in decoder.decode(currentFile.readStream!)) {
      items.add(str);
      yield items;
    }
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
