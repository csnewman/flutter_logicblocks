import 'package:flutter/material.dart';

import '../block.dart';
import '../block_target.dart';
import '../draggable_block.dart';
import 'block_body.dart';
import 'block_helpers.dart';
import 'constants.dart';
import 'theme.dart';

abstract class ModernBlockElement {
  ModernBlockBodyElement build(BuildContext context, ModernBlock block);
}

class MaterialBlockContentElement extends ModernBlockElement {
  final Widget content;
  final bool leftPad;

  MaterialBlockContentElement({
    @required this.content,
    this.leftPad = true,
  });

  @override
  ModernBlockBodyElement build(BuildContext context, ModernBlock block) {
    return ModernBlockBodyElement(
      background: true,
      leftPad: leftPad,
      child: content,
    );
  }
}

class MaterialBlockChildBlockElement extends ModernBlockElement {
  final String block;
  final BlockDropped blockDropped;
  final OnRemoved blockRemoved;

  MaterialBlockChildBlockElement({
    @required this.block,
    @required this.blockDropped,
    @required this.blockRemoved,
  })  : assert(blockDropped != null),
        assert(blockRemoved != null);

  @override
  ModernBlockBodyElement build(BuildContext context, ModernBlock block) {
    var block = BlockContext.of(context);
    bool silhouette = block.mode == BlockRenderMode.DragSilhouette;

    return ModernBlockBodyElement(
      background: false,
      topPad: false,
      bottomPad: false,
      trailOverlap:
          !silhouette && this.block != null ? triggerHeight - notchHeight : 0,
      child: !silhouette && this.block != null
          ? buildChildWidget(block)
          : ModernBlockTarget(
              blockDropped: blockDropped,
            ),
    );
  }

  Widget buildChildWidget(BlockContext block) {
    return DraggableBlock(
      id: this.block,
      mode: block.mode,
      isRoot: false,
      onRemoved: blockRemoved,
      dragPlaceholder: Padding(
        padding: EdgeInsets.only(bottom: triggerHeight - notchHeight),
        child: ModernBlockReplaceHolder(
          block: this.block,
        ),
      ),
    );
  }
}

class ModernBlock extends StatelessWidget {
  final bool isStartBlock;
  final ModernBlockTheme theme;
  final List<ModernBlockElement> elements;
  final bool allowNextBlock;
  final String nextBlock;
  final BlockDropped nextBlockDropped;
  final OnRemoved nextBlockRemoved;

  ModernBlock({
    @required this.isStartBlock,
    @required this.theme,
    @required this.elements,
    @required this.allowNextBlock,
    this.nextBlock,
    this.nextBlockDropped,
    this.nextBlockRemoved,
  })  : assert(isStartBlock != null),
        assert(theme != null),
        assert(elements != null && elements.length > 0),
        assert(nextBlockDropped != null),
        assert(nextBlockRemoved != null);

  @override
  Widget build(BuildContext context) {
    var block = BlockContext.of(context);
    bool silhouette = block.mode == BlockRenderMode.DragSilhouette;

    return DefaultTextStyle(
      style: Theme.of(context).textTheme.body1.apply(
            color: Colors.white,
          ),
      child: Builder(builder: (context) {
        var bodyElements = List<ModernBlockBodyElement>();

        for (var elm in elements) {
          bodyElements.add(elm.build(context, this));
        }

        if (!silhouette) {
          bodyElements.add(
            ModernBlockBodyElement(
              background: false,
              leftPad: false,
              topPad: false,
              bottomPad: false,
              child: nextBlock != null
                  ? buildNextWidget(block)
                  : ModernBlockTarget(
                      blockDropped: nextBlockDropped,
                      silhouettePadding: EdgeInsets.only(
                        bottom: triggerHeight - notchHeight,
                      ),
                    ),
            ),
          );
        }

        return ModernBlockBody(
          isStartBlock: isStartBlock,
          theme: theme,
          children: bodyElements,
        );
      }),
    );
  }

  Widget buildNextWidget(BlockContext block) {
    return DraggableBlock(
      id: nextBlock,
      mode: block.mode,
      isRoot: false,
      onRemoved: nextBlockRemoved,
      dragPlaceholder: Padding(
        padding: EdgeInsets.only(bottom: triggerHeight - notchHeight),
        child: ModernBlockReplaceHolder(
          block: nextBlock,
        ),
      ),
    );
  }
}
