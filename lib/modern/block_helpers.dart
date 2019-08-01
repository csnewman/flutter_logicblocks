import 'package:flutter/widgets.dart';

import '../block.dart';
import '../block_target.dart';
import '../fixed_block.dart';
import 'constants.dart';

class ModernBlockReplaceHolder extends StatelessWidget {
  final String block;

  ModernBlockReplaceHolder({
    @required this.block,
  }) : assert(block != null);

  @override
  Widget build(BuildContext context) {
    return SingleBlockTarget(
      placeholder: IgnorePointer(
        child: Container(
          constraints: BoxConstraints.tightFor(
            width: triggerWidth,
            height: triggerHeight,
          ),
//          decoration: BoxDecoration(color: Colors.yellow),
        ),
      ),
      canAccept: (id) {
        return id == block;
      },
      onDropped: (id, pos) {
        return false;
      },
    );
  }
}

class ModernBlockTarget extends StatelessWidget {
  final BlockDropped blockDropped;
  final EdgeInsets silhouettePadding;

  ModernBlockTarget({
    @required this.blockDropped,
    this.silhouettePadding = const EdgeInsets.only(),
  })  : assert(blockDropped != null),
        assert(silhouettePadding != null);

  @override
  Widget build(BuildContext context) {
    return BlockTarget(
      acceptMultiple: false,
      triggerHover: true,
      onDropped: blockDropped,
      builder: (context, valid, invalid) {
        return valid.length != 0
            ? Padding(
                padding: silhouettePadding,
                child: FixedBlock(
                  id: valid[0],
                  mode: BlockRenderMode.DragSilhouette,
                  isRoot: true,
                ),
              )
            : Container(
                constraints: BoxConstraints.tightFor(
                  width: triggerWidth,
                  height: triggerHeight,
                ),
//            decoration: BoxDecoration(color: Colors.pink),
              );
      },
    );
  }
}
