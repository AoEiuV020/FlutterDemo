import 'package:drift/drift.dart';

import 'database_flutter.dart' if (dart.library.js_util) 'database_web.dart';

part 'database.g.dart';

class TodoItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 6, max: 32)();
  TextColumn get content => text().named('body')();
  IntColumn get category => integer().nullable()();
}

@DriftDatabase(tables: [TodoItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftOpenConnection());

  @override
  int get schemaVersion => 1;

  Future<int> itemUpdate(TodoItem newItem, int add) =>
      into(todoItems).insert(newItem,
          onConflict: DoUpdate(
            (old) => TodoItemsCompanion.custom(
              title: Constant(newItem.title),
              content: Constant(newItem.content),
              category: old.category + Constant(add),
            ),
          ));

  Future<int> itemAdd(String title, String content, int category) =>
      into(todoItems).insert(TodoItemsCompanion.insert(
        title: title,
        content: content,
        category: Value(category),
      ));

  Future<int> itemDelete(Set<int> idSet) =>
      (delete(todoItems)..where((t) => t.id.isIn(idSet))).go();
}
