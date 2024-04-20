import 'package:demo/src/db/database.dart';
import 'package:flutter/material.dart';

import 'todo_item_line.dart';

class DatabaseOperator extends StatefulWidget {
  final AppDatabase database;

  const DatabaseOperator(this.database, {super.key});

  @override
  State<DatabaseOperator> createState() => _DatabaseOperatorState();
}

class _DatabaseOperatorState extends State<DatabaseOperator> {
  List<TodoItem> items = [];

  @override
  void initState() {
    super.initState();
    list();
  }

  void list() async {
    final database = widget.database;
    final list = await database.select(database.todoItems).get();
    setState(() {
      items.addAll(list);
    });
  }

  void add() async {
    final database = widget.database;
    final count = items.isEmpty ? 1 : items.length;
    for (var i = 0; i < count; i++) {
      final title = 'title $i';
      final content = 'content $i';
      final id = await database
          .into(database.todoItems)
          .insert(TodoItemsCompanion.insert(
            title: title,
            content: content,
          ));
      final item = TodoItem(id: id, title: title, content: content);
      setState(() {
        items.add(item);
      });
    }
  }

  void remove() async {
    final database = widget.database;
    final count = items.isEmpty ? 0 : (items.length / 2).ceil();
    final set = items.sublist(0, count).map((e) => e.id).toSet();
    await (database.delete(database.todoItems)..where((t) => t.id.isIn(set)))
        .go();
    setState(() {
      items.removeRange(0, count);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const CircularProgressIndicator(),
            ElevatedButton(
              onPressed: list,
              child: const Text('刷新'),
            ),
            ElevatedButton(
              onPressed: add,
              child: const Text('添加'),
            ),
            ElevatedButton(
              onPressed: remove,
              child: const Text('删除'),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return TodoItemLine(items[index]);
            },
          ),
        ),
      ],
    );
  }
}
