import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<String> fetchContent(http.Client client) async {
  final response = await client
      .get(Uri.parse('https://example.com/'));

  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw Exception('Failed to load content');
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Future<String> futureContent;

  @override
  void initState() {
    super.initState();
    futureContent = fetchContent(http.Client());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fetch Data Example'),
        ),
        body: Center(
          child: FutureBuilder<String>(
            future: futureContent,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.requireData);
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}