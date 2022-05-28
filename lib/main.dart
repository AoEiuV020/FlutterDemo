import 'dart:developer';

import 'package:demo/client.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo AoEiuV020'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final defaultUrl = "http://localhost:3000";
  final urlController = TextEditingController();
  final sb = StringBuffer();
  late Function(String) handler;

  @override
  void initState() {
    super.initState();
    handler = (String data) {
      setState(() {
        sb.writeln(data);
      });
    };
    connect(defaultUrl, handler);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
            child: Text(sb.toString()),
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          var newUrl;
          if (urlController.text.isEmpty) {
            newUrl = defaultUrl;
          } else {
            newUrl = urlController.text;
          }
          log('onPressed: ${newUrl}');
          setState(() {
            sb.clear();
            connect(newUrl, handler);
          });
        },
        tooltip: 'Show me the value!',
        child: const Icon(Icons.keyboard_return),
      ),
    );
  }
}
