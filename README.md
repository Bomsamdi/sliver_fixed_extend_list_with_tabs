# SliverFixedExtendListWithTabs

[![Pub Version](https://img.shields.io/pub/v/sliver_fixed_extend_list_with_tabs)](https://pub.dev/packages/sliver_fixed_extend_list_with_tabs)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![pub points](https://img.shields.io/pub/points/sliver_fixed_extend_list_with_tabs)](https://pub.dev/packages/sliver_fixed_extend_list_with_tabs/score) 
[![popularity](https://img.shields.io/pub/popularity/sliver_fixed_extend_list_with_tabs)](https://pub.dev/packages/sliver_fixed_extend_list_with_tabs/score)

A Flutter package that provides a sliver widget with a customizable tab bar and a fixed-extend list of items, including parents and children. If the last section (parent and its children) is too short to reach the top of the screen, the package offers a customizable footer to fill the missing space.

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  sliver_fixed_extend_list_with_tabs: ^0.0.1
```

## Usage
Use the SliverFixedExtendListWithTabs widget in your app. Customize the tab bar, list items, and footer according to your needs.

```dart
import 'package:flutter/material.dart';
import 'package:sliver_fixed_extend_list_with_tabs/sliver_fixed_extend_list_with_tabs.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SliverFixedExtendListWithTabs Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'SliverFixedExtendListWithTabs Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Section> sections = [];
  double listItemHeight = 100;
  @override
  void initState() {
    super.initState();
    double offsetStart = 0;
    List<ChildItem> children = List.generate(
      3,
      (index) => const Child(),
    );
    for (int i = 0; i < 10; i++) {
      Header header = Header(
        key: ValueKey(i),
        name: 'Header item $i',
        offsetStart: offsetStart,
        childrenCount: children.length,
        childrenHeight: listItemHeight,
      );
      sections.add(Section(
        header: header,
        children: children,
      ));
      offsetStart = header.offsetEnd;
    }
  }

  Widget buildHeader(BuildContext context, HeaderItem item) {
    Header header = item as Header;
    return Container(
      color: Colors.orange,
      child: Center(
        child: Text(
          header.name,
          style: const TextStyle(fontSize: 30),
        ),
      ),
    );
  }

  Widget buildChild(BuildContext context, ChildItem item) {
    return Container(
      color: Colors.blue.shade400,
      child: const Center(
        child: Text(
          'Child item',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              collapsedHeight: kToolbarHeight,
              pinned: true,
              title: Text(widget.title),
            ),
            SliverFixedExtendListWithTabs(
              controller: PrimaryScrollController.of(context),
              indicatorPadding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              tabBarIndicator: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  25.0,
                ),
                color: Colors.green,
              ),
              listItemHeight: listItemHeight,
              sections: sections,
              headerBuilder: buildHeader,
              childBuilder: buildChild,
              startOffset: 200 - kToolbarHeight,
              customFooterWidget: const Center(
                child: FlutterLogo(
                  size: 200,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Header extends HeaderItem {
  Header({
    required super.key,
    required this.name,
    required super.offsetStart,
    required super.childrenCount,
    required super.childrenHeight,
  });
  final String name;
}

class Child extends ChildItem {
  const Child();
}
```

## Features

- Sliver widget with a customizable tab bar.
- Fixed-extend list of items, including parents and children.
- Customizable footer to fill the missing space if the last section is too short.

## Configuration

Customize the appearance and behavior of the SliverFixedExtendListWithTabs widget through various configuration options.

## Issues and Bugs

Report any issues or bugs on the GitHub issues page.

## License

This package is licensed under the MIT License.
