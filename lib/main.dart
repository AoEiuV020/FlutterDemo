import 'package:flutter/material.dart';
import 'package:native_add/native_add.dart' as native_add;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo AoEiuV020',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo AoEiuV020 Home Page'),
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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter = native_add.sum(_counter, 1);
    });
  }

  void _incrementCounterString() {
    setState(() {
      _counter = int.parse(
        native_add.sumString(_counter.toString(), 1.toString()),
      );
    });
  }

  Future<void> _incrementCounterAsync() async {
    final result = await native_add.sumAsync(_counter, 1);
    setState(() {
      _counter = result;
    });
  }

  // 添加新方法处理HTTP调用
  Future<void> _incrementCounterViaHttp() async {
    try {
      final result = await native_add.sumViaHttp(_counter, 1);
      setState(() {
        _counter = result;
      });
    } catch (e) {
      // 显示错误信息
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('错误: $e')));
    }
  }

  // 添加新方法调用increase函数
  void _incrementViaIncrease() {
    setState(() {
      _counter = native_add.increase();
    });
  }

  // 添加新方法调用goCallAsync测试SumLongRunning
  Future<void> _callGoAsyncSumLongRunning() async {
    try {
      // 调用goCallAsync方法，指定方法名为'SumLongRunning'，传递参数
      final result = await native_add.goCallAsync('SumLongRunning', {
        'a': _counter,
        'b': 1,
      });

      // 从结果Map中获取sum字段的值
      final int sum = result['result'] as int;

      setState(() {
        _counter = sum;
      });
    } catch (e) {
      // 显示错误信息
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('goCallAsync错误: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: _incrementCounter,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            onPressed: _incrementCounterString,
            tooltip: 'Increment String',
            child: const Icon(Icons.title),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            onPressed: _incrementCounterAsync,
            tooltip: 'Increment Async',
            child: const Icon(Icons.timer),
          ),
          const SizedBox(width: 16),
          // 添加新按钮
          FloatingActionButton(
            onPressed: _incrementCounterViaHttp,
            tooltip: 'Increment via HTTP',
            child: const Icon(Icons.http),
          ),
          const SizedBox(width: 16),
          // 添加调用increase函数的按钮
          FloatingActionButton(
            onPressed: _incrementViaIncrease,
            tooltip: 'Global Increment',
            child: const Icon(Icons.plus_one),
          ),
          const SizedBox(width: 16),
          // 添加测试goCallAsync的按钮
          FloatingActionButton(
            onPressed: _callGoAsyncSumLongRunning,
            tooltip: 'Go Call Async',
            child: const Icon(Icons.api),
          ),
        ],
      ),
    );
  }
}
