import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'block_path.dart';
import 'constants.dart';
import 'theme.dart';

class ModernBlockBodyElement extends ParentDataWidget<ModernBlockBody> {
  final double leadOverlap;
  final double trailOverlap;
  final bool background;

  ModernBlockBodyElement({
    Key key,
    @required this.background,
    @required Widget child,
    bool leftPad = true,
    bool topPad = true,
    bool bottomPad = true,
    this.leadOverlap = notchHeight,
    this.trailOverlap = 0,
  }) : super(
          key: key,
          child: Container(
            padding: EdgeInsets.only(
              top: topPad ? notchHeight : 0,
              bottom: bottomPad ? notchHeight : 0,
              left: leftPad ? 10 : 0,
            ),
            child: child,
          ),
        );

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is ModernBlockBodyParentData);
    final ModernBlockBodyParentData parentData = renderObject.parentData;
    bool needsLayout = false;

    if (parentData.leadOverlap != leadOverlap) {
      parentData.leadOverlap = leadOverlap;
      needsLayout = true;
    }

    if (parentData.trailOverlap != trailOverlap) {
      parentData.trailOverlap = trailOverlap;
      needsLayout = true;
    }

    if (parentData.background != background) {
      parentData.background = background;
      needsLayout = true;
    }

    if (needsLayout) {
      final AbstractNode targetParent = renderObject.parent;
      if (targetParent is RenderObject) targetParent.markNeedsLayout();
    }
  }
}

class ModernBlockBody extends MultiChildRenderObjectWidget {
  final bool isStartBlock;
  final ModernBlockTheme theme;

  ModernBlockBody({
    Key key,
    @required this.isStartBlock,
    @required this.theme,
    @required List<ModernBlockBodyElement> children,
  })  : assert(isStartBlock != null),
        assert(theme != null),
        assert(children != null),
        assert(children.length > 0),
        super(key: key, children: children);

  @override
  RenderModernBlockBody createRenderObject(BuildContext context) {
    return RenderModernBlockBody()
      ..theme = theme
      ..isStartBlock = isStartBlock;
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderModernBlockBody renderObject) {
    renderObject
      ..theme = theme
      ..isStartBlock = isStartBlock;
  }
}

class ModernBlockBodyParentData extends ContainerBoxParentData<RenderBox> {
  double leadOverlap = 0;
  double trailOverlap = 0;
  bool background = false;

  @override
  String toString() =>
      '${super.toString()}; leadOverlap=$leadOverlap; trailOverlap=$trailOverlap, trailOverlap=$trailOverlap';
}

typedef _ChildSizingFunction = double Function(RenderBox child, double extent);

class RenderModernBlockBody extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, ModernBlockBodyParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, ModernBlockBodyParentData>,
        DebugOverflowIndicatorMixin {
  ModernBlockTheme theme;
  bool isStartBlock;

  RenderModernBlockBody({
    List<RenderBox> children,
    this.isStartBlock,
  }) {
    addAll(children);
  }

  Path _lastShape;

  double _overflow = 0;

  bool get _hasOverflow => _overflow > precisionErrorTolerance;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! ModernBlockBodyParentData)
      child.parentData = ModernBlockBodyParentData();
  }

  double _getIntrinsicSize({
    Axis sizingDirection,
    double extent,
    _ChildSizingFunction childSize,
  }) {
    if (sizingDirection == Axis.vertical) {
      double totalSpace = 0.0;
      RenderBox child = firstChild;
      bool first = true;
      while (child != null) {
        final ModernBlockBodyParentData childParentData = child.parentData;

        var size = childSize(child, extent);

        if (!first) {
          size -= (childParentData.leadOverlap ?? 0);
        }

        if (childParentData.nextSibling != null) {
          size -= (childParentData.trailOverlap ?? 0);
        }

        totalSpace += size;

        child = childParentData.nextSibling;
        first = false;
      }
      return totalSpace;
    } else {
      double maxCrossSize = 0.0;
      RenderBox child = firstChild;
      while (child != null) {
        double mainSize = child.getMaxIntrinsicHeight(double.infinity);
        double crossSize = childSize(child, mainSize);

        maxCrossSize = math.max(maxCrossSize, crossSize);

        final ModernBlockBodyParentData childParentData = child.parentData;
        child = childParentData.nextSibling;
      }

      return maxCrossSize;
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return _getIntrinsicSize(
      sizingDirection: Axis.horizontal,
      extent: height,
      childSize: (RenderBox child, double extent) =>
          child.getMinIntrinsicWidth(extent),
    );
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return _getIntrinsicSize(
      sizingDirection: Axis.horizontal,
      extent: height,
      childSize: (RenderBox child, double extent) =>
          child.getMaxIntrinsicWidth(extent),
    );
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return _getIntrinsicSize(
      sizingDirection: Axis.vertical,
      extent: width,
      childSize: (RenderBox child, double extent) =>
          child.getMinIntrinsicHeight(extent),
    );
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return _getIntrinsicSize(
      sizingDirection: Axis.vertical,
      extent: width,
      childSize: (RenderBox child, double extent) =>
          child.getMaxIntrinsicHeight(extent),
    );
  }

  @override
  void performLayout() {
    assert(constraints != null);

    // Find the largest sized element with background
    double bodyWidth = 0;
    RenderBox child = firstChild;
    while (child != null) {
      final ModernBlockBodyParentData childParentData = child.parentData;

      if (childParentData.background) {
        child.layout(
          BoxConstraints(maxWidth: constraints.maxWidth),
          parentUsesSize: true,
        );
        bodyWidth = math.max(bodyWidth, child.size.width);
      }

      child = childParentData.nextSibling;
    }
    bodyWidth = math.min(bodyWidth, constraints.maxWidth);

    // Perform actual layout
    double totalWidth = 0.0;
    double totalHeight = 0.0;
    child = firstChild;
    bool first = true;
    while (child != null) {
      final ModernBlockBodyParentData childParentData = child.parentData;

      // All elements with backgrounds must have the same size
      BoxConstraints innerConstraints = childParentData.background
          ? BoxConstraints(minWidth: bodyWidth, maxWidth: bodyWidth)
          : BoxConstraints(maxWidth: constraints.maxWidth);
      child.layout(innerConstraints, parentUsesSize: true);

      // Adjust size
      totalWidth = math.max(totalWidth, child.size.width);
      totalHeight += child.size.height;
      if (!first) {
        totalHeight -= (childParentData.leadOverlap ?? 0);
      }

      if (childParentData.nextSibling != null) {
        totalHeight -= (childParentData.trailOverlap ?? 0);
      }

      assert(child.parentData == childParentData);
      child = childParentData.nextSibling;
      first = false;
    }

    // Ensure content fits
    size = constraints.constrain(Size(totalWidth, totalHeight));
    _overflow = math.max(0.0, totalHeight - size.height);

    // Position elements
    double currentPos = 0;
    child = firstChild;
    first = true;
    while (child != null) {
      final ModernBlockBodyParentData childParentData = child.parentData;

      // Adjust position with overlaps
      currentPos -= (first ? 0 : (childParentData.leadOverlap ?? 0));

      childParentData.offset = Offset(0, currentPos);

      currentPos += child.size.height -
          (childParentData.nextSibling == null ||
                  childParentData.trailOverlap == null
              ? 0
              : childParentData.trailOverlap);

      child = childParentData.nextSibling;
      first = false;
    }

    // Build shape
    var builder = ModernBlockPathBuilder(
      circleTop: isStartBlock,
    );
    builder.start();
    child = firstChild;
    bool hadBody = false;
    while (child != null) {
      final ModernBlockBodyParentData childParentData = child.parentData;
      final RenderBox next = childParentData.nextSibling;

      if (childParentData.background) {
        builder.addBlock(
          childParentData.offset.dy,
          child.size,
          !hadBody,
          !_hasMoreBodies(next),
        );
      }

      hadBody |= childParentData.background;
      child = next;
    }
    builder.end();
    _lastShape = builder.path;
  }

  bool _hasMoreBodies(RenderBox child) {
    while (child != null) {
      final ModernBlockBodyParentData childParentData = child.parentData;

      if (childParentData.background) {
        return true;
      }

      child = childParentData.nextSibling;
    }

    return false;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    if (defaultHitTestChildren(result, position: position)) {
      return true;
    }

    return _lastShape != null && _lastShape.contains(position);
  }

  @override
  Rect describeApproximatePaintClip(RenderObject child) =>
      _hasOverflow ? Offset.zero & size : null;

  void paintContent(PaintingContext context, Offset offset) {
    if (_lastShape == null) {
      return;
    }

    // Draw shadow
    var canvas = context.canvas;
    final paint = Paint();
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.drawShadow(_lastShape, Colors.grey[900], 2.0, true);
    canvas.restore();

    // Draw children without backgrounds
    RenderBox child = firstChild;
    while (child != null) {
      final ModernBlockBodyParentData childParentData = child.parentData;
      if (!childParentData.background) {
        context.paintChild(child, childParentData.offset + offset);
      }
      child = childParentData.nextSibling;
    }

    // Draw body
    canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    paint.color = theme.background;
    canvas.drawPath(_lastShape, paint);

    // Draw border
    paint.color = theme.border;
    paint.strokeWidth = 2;
    paint.style = PaintingStyle.stroke;
    canvas.drawPath(_lastShape, paint);
    canvas.restore();

    // Draw children with backgrounds
    child = firstChild;
    while (child != null) {
      final ModernBlockBodyParentData childParentData = child.parentData;
      if (childParentData.background) {
        context.paintChild(child, childParentData.offset + offset);
      }
      child = childParentData.nextSibling;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) async {
    if (!_hasOverflow) {
      paintContent(context, offset);
      return;
    }

    // Clip content
    context.pushClipRect(
      needsCompositing,
      offset,
      Offset.zero & size,
      paintContent,
    );

    // Draw warning indicator
    assert(() {
      paintOverflowIndicator(
        context,
        offset,
        Offset.zero & size,
        Rect.fromLTWH(
          0.0,
          0.0,
          0.0,
          size.height + _overflow,
        ),
      );
      return true;
    }());
  }
}
