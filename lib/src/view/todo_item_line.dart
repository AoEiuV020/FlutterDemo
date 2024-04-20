import 'package:demo/src/db/database.dart';
import 'package:flutter/material.dart';

class TodoItemLine extends StatelessWidget {
  final TodoItem item;

  const TodoItemLine(this.item, {super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("${item.id}: ${item.title}"),
        Text("${item.category} ${item.content}"),
      ],
    );
  }
}
