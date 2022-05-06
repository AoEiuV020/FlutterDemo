import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'get.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<String> futureContent;
  final defaultUrl = "https://jsonplaceholder.typicode.com/albums/1";
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureContent = fetchUrl(http.Client(), defaultUrl);
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
        body: Column(children: [
          TextField(
            controller: urlController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: defaultUrl,
            ),
          ),
          Flexible(
            flex: 1,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: FutureBuilder<String>(
                future: futureContent,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      snapshot.requireData,
                    );
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  }
                  // By default, show a loading spinner.
                  return const CircularProgressIndicator();
                },
              ),
            ),
          ),
        ]),
        floatingActionButton: FloatingActionButton(
          // When the user presses the button, show an alert dialog containing
          // the text that the user has entered into the text field.
          onPressed: () {
            log('onPressed: ${urlController.text}');
            setState(() {
              futureContent = fetchUrl(http.Client(), urlController.text);
            });
          },
          tooltip: 'Show me the value!',
          child: const Icon(Icons.keyboard_return),
        ),
      ),
    );
  }
}
