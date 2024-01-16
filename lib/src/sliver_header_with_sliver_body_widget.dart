import 'package:flutter/material.dart';
import 'package:sliver_fixed_extend_list_with_tabs/src/render_sliver_header_with_sliver_body_widget.dart';

/// [SliverHeaderWithSliverBodyWidget] allows for returning multiple slivers from a single build method
class SliverHeaderWithSliverBodyWidget extends MultiChildRenderObjectWidget {
  // flutter pre 3.13 does not allow the constructor to be const
  // ignore: prefer_const_constructors_in_immutables
  SliverHeaderWithSliverBodyWidget({
    Key? key,
    required Widget header,
    required Widget body,
    this.pushPinnedChildren = false,
    double? footerHeight,
    Widget? footerWidget,
  }) : super(key: key, children: [
          header,
          body,
          if (footerHeight != null)
            SliverToBoxAdapter(
              child: SizedBox(
                height: footerHeight,
                child: footerWidget,
              ),
            )
        ]);

  /// If true any children that paint beyond the layoutExtent of the entire [SliverHeaderWithSliverBodyWidget] will
  /// be pushed off towards the leading edge of the [Viewport]
  final bool pushPinnedChildren;

  @override
  RenderSliverHeaderWithSliverBodyWidget createRenderObject(
          BuildContext context) =>
      RenderSliverHeaderWithSliverBodyWidget(
        containing: pushPinnedChildren,
      );

  @override
  void updateRenderObject(BuildContext context,
      covariant RenderSliverHeaderWithSliverBodyWidget renderObject) {
    renderObject.containing = pushPinnedChildren;
  }
}
