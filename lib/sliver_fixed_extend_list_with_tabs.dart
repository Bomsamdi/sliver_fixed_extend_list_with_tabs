library sliver_fixed_extend_list_with_tabs;

import 'dart:async';

import 'package:after_first_frame_mixin/after_first_frame_mixin.dart';
import 'package:flutter/material.dart';
import 'package:sliver_fixed_extend_list_with_tabs/src/sliver_header_with_sliver_body_widget.dart';
import 'package:sliver_tools/sliver_tools.dart';

typedef HeaderBuilder = Widget Function(BuildContext context, HeaderItem item);
typedef ChildBuilder = Widget Function(BuildContext context, ChildItem item);

const double _kTabHeight = 46.0;

/// A sliver list with a fixed extent and tabs.
class SliverFixedExtendListWithTabs extends StatefulWidget {
  const SliverFixedExtendListWithTabs({
    Key? key,
    required this.listItemHeight,
    required this.controller,
    required this.childBuilder,
    required this.sections,
    this.scrollAnimated = true,
    this.headerBuilder,
    this.startOffset = 0,
    this.tabBarIndicator,
    this.tabBarBackgroundColor,
    this.indicatorPadding = EdgeInsets.zero,
    this.tabBarIndicatorSize = TabBarIndicatorSize.tab,
    this.tabAlignment = TabAlignment.start,
    this.tabBarCurveAnimation = Curves.linear,
    this.listScrollCurveAnimation = Curves.easeInOut,
    this.customFooterWidget,
  }) : super(key: key);

  /// The height of each item in the list.
  final double listItemHeight;

  /// The padding for the indicator.
  final EdgeInsetsGeometry indicatorPadding;

  /// The size of the indicator.
  final TabBarIndicatorSize tabBarIndicatorSize;

  /// The alignment of the tabs.
  final TabAlignment tabAlignment;

  /// The curve animation of the tab bar.
  final Curve tabBarCurveAnimation;

  /// The curve animation of the list scroll.
  final Curve listScrollCurveAnimation;

  /// The list of sections to display.
  final List<Section> sections;

  /// The controller to use for the scroll view.
  final ScrollController controller;

  /// Whether to animate the scroll when the tab is tapped.
  final bool scrollAnimated;

  /// The builder to use for the header items.
  final HeaderBuilder? headerBuilder;

  /// The builder to use for the child items.
  final ChildBuilder childBuilder;

  /// The start offset of the list. It is needed when
  ///
  ///  in [CustomScrollView] before [SliverFixedExtendListWithTabs]
  ///
  ///  exist some other slivers.
  final double startOffset;

  /// The indicator of the tab bar item.
  final Decoration? tabBarIndicator;

  /// The background color of the tab bar.
  final Color? tabBarBackgroundColor;

  /// The widget to use for the footer.
  final Widget? customFooterWidget;

  @override
  State<SliverFixedExtendListWithTabs> createState() =>
      _SliverFixedExtendListWithTabsState();
}

class _SliverFixedExtendListWithTabsState
    extends State<SliverFixedExtendListWithTabs>
    with SingleTickerProviderStateMixin, AfterFirstFrameMixin {
  /// The tab controller.
  TabController? _tabController;

  /// The height of each item in the list.
  late double _listItemHeight;

  /// The list of items to display.
  final List<ListItem> _items = [];

  List<Section> _sections = [];

  /// The list of tab items to display.
  late List<TabItem> _tabItems;

  /// Enable/disable scroll animation when list animate to
  ///
  ///  position. This is needed to sync tabs and list.
  bool scrollAnimationEnabled = true;

  /// The current index of the tab controller.
  int _index = 0;

  /// The index of the last header item.
  int? _indexOfLastHeaderItem;

  /// The height of the footer. When in last group of items there
  ///
  ///  is not enough items to fill the screen, the footer is used to fill the screen.
  double? _footerHeight;

  @override
  void initState() {
    super.initState();
    _listItemHeight = widget.listItemHeight;
    _sections = widget.sections;
    _tabController = TabController(length: _sections.length, vsync: this);
    for (Section section in _sections) {
      _items.add(section.header);
      for (ChildItem childItem in section.children) {
        _items.add(childItem);
      }
    }
    _tabItems = [];
    int count = 0;
    for (var i = 0; i < _sections.length; i++) {
      _tabItems.add(TabItem(
        key: ValueKey(count),
        headerItem: _sections[i].header,
        text: 'Tab ${_tabItems.length} $count',
      ));
      count += _sections[i].children.length + 1;
    }
    _indexOfLastHeaderItem =
        _items.lastIndexWhere((element) => element is HeaderItem);
    if (_indexOfLastHeaderItem == -1) {
      _indexOfLastHeaderItem = null;
    }

    widget.controller.addListener(() {
      if (scrollAnimationEnabled) {
        HeaderItem item =
            _items.whereType<HeaderItem>().toList().firstWhere((element) {
          final HeaderItem headerItem = element;
          return widget.controller.offset >=
                  headerItem.offsetStart + widget.startOffset &&
              widget.controller.offset <
                  headerItem.offsetEnd + widget.startOffset;
        }, orElse: () => _items.first as HeaderItem);
        int a = (item.key as ValueKey).value;
        if (a != _index) {
          _index = a;
          _tabController?.animateTo(
            _index,
            duration: const Duration(milliseconds: 300),
            curve: widget.listScrollCurveAnimation,
          );
          setState(() {});
        }
      }
    });
  }

  @override
  FutureOr<void> afterFirstFrame(BuildContext context) {
    if (_indexOfLastHeaderItem != null) {
      Size size = MediaQuery.of(context).size;
      double height = size.height;
      final padding = MediaQuery.of(context).viewPadding;
      height = height - padding.top - padding.bottom;
      double elementHeight =
          _items.skip(_indexOfLastHeaderItem!).length * _listItemHeight;
      if (height > elementHeight) {
        _footerHeight = (height - elementHeight).ceilToDouble();
        setState(() {});
      }
    }
  }

  @override
  void didUpdateWidget(covariant SliverFixedExtendListWithTabs oldWidget) {
    if (oldWidget.listItemHeight != widget.listItemHeight) {
      setState(() {
        _listItemHeight = widget.listItemHeight;
      });
    }
    if (oldWidget.sections != widget.sections) {
      _sections.clear();
      _items.clear();
      _sections = widget.sections;
      for (Section section in _sections) {
        _items.add(section.header);
        for (ChildItem childItem in section.children) {
          _items.add(childItem);
        }
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _onTapTabBarItem(int value) {
    scrollAnimationEnabled = false;
    final ValueKey dataKey = _tabItems[value].key as ValueKey;
    widget.scrollAnimated
        ? widget.controller
            .animateTo(
              dataKey.value * _listItemHeight + widget.startOffset,
              duration: const Duration(milliseconds: 300),
              curve: widget.tabBarCurveAnimation,
            )
            .then((value) => scrollAnimationEnabled = true)
        : widget.controller.jumpTo(dataKey.value * _listItemHeight);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return SliverHeaderWithSliverBodyWidget(
      pushPinnedChildren: true,
      header: SliverPinnedHeader(
        child: Container(
          color: widget.tabBarBackgroundColor ?? theme.scaffoldBackgroundColor,
          child: TabBar(
            isScrollable: true,
            indicator: widget.tabBarIndicator,
            indicatorPadding: widget.indicatorPadding,
            indicatorSize: widget.tabBarIndicatorSize,
            tabAlignment: widget.tabAlignment,
            controller: _tabController,
            onTap: _onTapTabBarItem,
            tabs: _tabItems,
          ),
        ),
      ),
      body: SliverFixedExtentList(
        itemExtent: _listItemHeight,
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            var item = _items[index];
            if (item is ChildItem) {
              return widget.childBuilder(context, item);
            } else if (item is HeaderItem && widget.headerBuilder != null) {
              return widget.headerBuilder!(context, item);
            } else {
              return Container();
            }
          },
          childCount: _items.length,
        ),
      ),
      footerHeight: _footerHeight,
      footerWidget: widget.customFooterWidget,
    );
  }
}

abstract class HeaderItem extends ListItem {
  const HeaderItem({
    required super.key,
    required this.offsetStart,
    required this.childrenCount,
    required this.childrenHeight,
  }) : offsetEnd =
            offsetStart + (childrenHeight * childrenCount) + childrenHeight;
  final double offsetStart;
  final double offsetEnd;
  final double childrenHeight;
  final int childrenCount;
}

abstract class ChildItem extends ListItem {
  const ChildItem({super.key});
}

abstract class ListItem {
  const ListItem({this.key});
  final Key? key;
}

class TabItem extends StatelessWidget implements PreferredSizeWidget {
  /// Creates a Material Design [SliverFixedExtendListWithTabs] tab.
  const TabItem({
    super.key,
    this.text,
    this.height,
    required this.headerItem,
  });

  /// The [HeaderItem] to display as the tab's label.
  final HeaderItem headerItem;

  /// The text to display as the tab's label.
  final String? text;

  /// The height of the [TabItem].
  ///
  /// If null, the height will be calculated based on the content of the [TabItem].
  final double? height;

  Widget buildLabelText() {
    return Text(text!, softWrap: false, overflow: TextOverflow.ellipsis);
  }

  @override
  Widget build(BuildContext context) {
    final Widget label;
    label = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        buildLabelText(),
      ],
    );

    return SizedBox(
      height: height ?? _kTabHeight,
      child: Center(
        widthFactor: 1.0,
        child: label,
      ),
    );
  }

  @override
  Size get preferredSize {
    if (height != null) {
      return Size.fromHeight(height!);
    } else {
      return const Size.fromHeight(_kTabHeight);
    }
  }
}

class Section {
  const Section({
    required this.header,
    required this.children,
  });
  final HeaderItem header;
  final List<ChildItem> children;

  static int getSectionItemsCount(
      HeaderItem? header, List<ChildItem> children) {
    return children.length + (header != null ? 1 : 0);
  }
}
