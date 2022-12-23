import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';

import 'get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo AoEiuV020'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<String> futureContent;
  final defaultUrl = "https://jsonplaceholder.typicode.com/albums/1";
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureContent = fetchUrl(defaultUrl);
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
              futureContent = fetchUrl(urlController.text);
            });
          },
          tooltip: 'Show me the value!',
          child: const Icon(Icons.keyboard_return),
        ),
      ),
    );
  }
}
