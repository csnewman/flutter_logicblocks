import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'block.dart';

import 'draggable_block.dart';
import 'block_target.dart';

typedef BlockProvider = Widget Function(
    BuildContext context, BlockContext block);
typedef RootBlocksProvider = List<RootBlock> Function();
typedef OnBlockMoved = void Function(String id, Offset canvasLocalPos);
typedef OnCanvasPan = void Function(Offset delta);

class CanvasContext extends InheritedWidget {
  final BlockProvider blockProvider;
  final RootBlocksProvider rootBlocksProvider;
  final OnBlockMoved onBlockMoved;
  final double zoom;
  final Offset offset;
  final dynamic extra;

  const CanvasContext({
    Key key,
    @required this.blockProvider,
    @required this.onBlockMoved,
    @required this.rootBlocksProvider,
    this.zoom = 1,
    this.offset,
    this.extra,
    @required Widget child,
  })  : assert(blockProvider != null),
        assert(onBlockMoved != null),
        assert(rootBlocksProvider != null),
        assert(child != null),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(CanvasContext old) =>
      blockProvider != old.blockProvider || onBlockMoved != old.onBlockMoved;

  static CanvasContext of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(CanvasContext) as CanvasContext;
  }
}

class BlockCanvasBackground extends StatelessWidget {
  final OnCanvasPan onPan;

  BlockCanvasBackground({
    this.onPan,
  });

  @override
  Widget build(BuildContext context) {
    final canvas = CanvasContext.of(context);
    assert(canvas != null);

    return BlockTarget(
      acceptMultiple: true,
      triggerHover: false,
      onDropped: (block, pos) {
        canvas.onBlockMoved(
            block,
            (context.findRenderObject() as RenderBox).globalToLocal(pos) -
                canvas.offset);
        return true;
      },
      builder: (context, valid, invalid) {
        return GestureDetector(
          onPanUpdate: (details) {
            if (onPan != null) {
              onPan(details.delta);
            }
          },
          child: Container(
            decoration: BoxDecoration(
//              color: Color.fromRGBO(249, 249, 249, 1),
//              color: Color.fromRGBO(20, 27, 44, 1),
              color: Color.fromRGBO(51, 71, 113, 1),
            ),
          ),
        );
      },
    );
  }
}

class RootBlock {
  final String block;
  final Offset position;

  RootBlock({
    @required this.block,
    @required this.position,
  });
}

class BlockCanvas extends StatelessWidget {
  final Widget background;

  BlockCanvas({
    @required this.background,
  });

  @override
  Widget build(BuildContext context) {
    final canvas = CanvasContext.of(context);

    var widgets = <Widget>[background];

    for (var block in canvas.rootBlocksProvider()) {
      widgets.add(
        Positioned(
          top: block.position.dy + canvas.offset.dy,
          left: block.position.dx + canvas.offset.dx,
          child: DraggableBlock(
            id: block.block,
            mode: BlockRenderMode.Standard,
            isRoot: true,
            onRemoved: () {},
            dragPlaceholder: Container(),
          ),
        ),
      );
    }

    return ClipRect(
      child: Stack(
        children: widgets,
      ),
    );
  }
}
