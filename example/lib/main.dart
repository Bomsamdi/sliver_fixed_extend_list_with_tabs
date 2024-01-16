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
  double listItemHeight = 80;
  @override
  void initState() {
    super.initState();
    double offsetStart = 0;
    List<ChildItem> children = List.generate(
      10,
      (index) => const Child(),
    );
    for (int i = 0; i < 11; i++) {
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
