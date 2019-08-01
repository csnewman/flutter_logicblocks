import 'package:flutter/widgets.dart';

import 'block.dart';
import 'fixed_block.dart';

typedef BlockDropped = bool Function(
  String id,
  Offset globalPosition,
);

class SingleBlockTarget extends StatelessWidget {
  final Widget placeholder;
  final BlockDropped onDropped;
  final BlockTargetAccept canAccept;

  SingleBlockTarget({
    @required this.placeholder,
    @required this.onDropped,
    this.canAccept,
  });

  @override
  Widget build(BuildContext context) {
    return BlockTarget(
      acceptMultiple: false,
      triggerHover: true,
      onDropped: onDropped,
      canAccept: canAccept,
      builder: (context, valid, invalid) {
        return valid.length != 0
            ? FixedBlock(
                id: valid[0],
                mode: BlockRenderMode.DragSilhouette,
                isRoot: true,
              )
            : placeholder;
      },
    );
  }
}

typedef BlockTargetBuilder = Widget Function(
  BuildContext context,
  List<String> candidateBlocks,
  List<String> rejectedBlocks,
);

typedef BlockTargetAccept = bool Function(
  String id,
);

class BlockTarget extends StatefulWidget {
  final DragTargetBuilder builder;
  final bool acceptMultiple;
  final BlockDropped onDropped;
  final bool triggerHover;
  final BlockTargetAccept canAccept;

  BlockTarget({
    @required this.builder,
    @required this.onDropped,
    @required this.acceptMultiple,
    @required this.triggerHover,
    this.canAccept,
  });

  @override
  BlockTargetState createState() => BlockTargetState();
}

class BlockTargetState extends State<BlockTarget> {
  final List<String> _candidateBlocks = <String>[];
  final List<String> _rejectedBlocks = <String>[];

  bool didEnter(String block) {
    assert(!_candidateBlocks.contains(block));
    assert(!_rejectedBlocks.contains(block));

    if ((widget.acceptMultiple || _candidateBlocks.length == 0) &&
        (widget.canAccept == null || widget.canAccept(block))) {
      setState(() {
        _candidateBlocks.add(block);
      });
      return true;
    }

    _rejectedBlocks.add(block);
    return false;
  }

  void didLeave(String block) {
    assert(_candidateBlocks.contains(block) || _rejectedBlocks.contains(block));
    if (!mounted) return;
    setState(() {
      _candidateBlocks.remove(block);
      _rejectedBlocks.remove(block);
    });
  }

  bool didDrop(String block, Offset globalPosition) {
    assert(_candidateBlocks.contains(block));
    if (!mounted) return false;
    setState(() {
      _candidateBlocks.remove(block);
    });

    var result = widget.onDropped(block, globalPosition);
    assert(result != null);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return MetaData(
      metaData: this,
      behavior: HitTestBehavior.translucent,
      child: widget.builder(
        context,
        _candidateBlocks,
        _rejectedBlocks,
      ),
    );
  }
}
