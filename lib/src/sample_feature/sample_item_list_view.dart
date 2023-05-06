import 'dart:io';

import 'package:flutter/material.dart';

import '../settings/settings_view.dart';
import 'sample_item.dart';
import 'sample_item_details_view.dart';

/// Displays a list of SampleItems.
class SampleItemListView extends StatelessWidget {
  const SampleItemListView({
    super.key,
    required this.currentDirectory,
  });

  static const routeName = '/';

  final Directory currentDirectory;

  Future<List<SampleItem>> getListFuture() {
    return currentDirectory.list().map((event) => SampleItem(event)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sample Items AoEiuV020'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),

      // To work with lists that may contain a large number of items, it’s best
      // to use the ListView.builder constructor.
      //
      // In contrast to the default ListView constructor, which requires
      // building all Widgets up front, the ListView.builder constructor lazily
      // builds Widgets as they’re scrolled into view.
      body: FutureBuilder(
          future: getListFuture(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text("no data");
            }
            var items = snapshot.data!;
            return ListView.builder(
              // Providing a restorationId allows the ListView to restore the
              // scroll position when a user leaves and returns to the app after it
              // has been killed while running in the background.
              restorationId: 'sampleItemListView',
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                final item = items[index];

                return ListTile(
                    title: Text(item.entity.path),
                    leading: item.entity is Directory
                        ? const Icon(Icons.folder_open)
                        : const Icon(Icons.file_open),
                    onTap: () {
                      if (item.entity is Directory) {
                        Navigator.restorablePushNamed(
                          context,
                          SampleItemListView.routeName,
                          arguments: item.entity.path,
                        );
                      } else {
                        Navigator.restorablePushNamed(
                          context,
                          SampleItemDetailsView.routeName,
                          arguments: item.entity.path,
                        );
                      }
                    });
              },
            );
          }),
    );
  }
}
