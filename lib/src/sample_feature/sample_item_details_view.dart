import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';

/// Displays detailed information about a SampleItem.
class SampleItemDetailsView extends StatelessWidget {
  const SampleItemDetailsView(this.currentFile, {super.key});

  static const routeName = '/sample_item';

  final File currentFile;

  Future<String> getFuture() async {
    try {
      return currentFile.readAsStringSync();
    } on FileSystemException catch(_) {
      return String.fromCharCodes(currentFile.readAsBytesSync());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentFile.path),
      ),
      body: Center(
        child: FutureBuilder(
          future: getFuture(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            if (!snapshot.hasData) {
              return Text("loading ${currentFile.path}");
            }
            return SingleChildScrollView(
              child: Text(snapshot.requireData),
            );
          }
        ),
      ),
    );
  }
}
