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
    connect(defaultInput, handler);
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
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: defaultInput,
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
          String newInput;
          if (urlController.text.isEmpty) {
            newInput = defaultInput;
          } else {
            newInput = urlController.text;
          }
          log('onPressed: $newInput');
          setState(() {
            sb.clear();
            connect(newInput, handler);
          });
        },
        tooltip: 'Show me the value!',
        child: const Icon(Icons.keyboard_return),
      ),
    );
  }
}