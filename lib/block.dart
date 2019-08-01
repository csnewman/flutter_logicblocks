import 'package:flutter/widgets.dart';

typedef BlockWidgetBuilder = Widget Function(
  BuildContext buildContext,
  BlockContext blockContext,
);

enum BlockRenderMode {
  Standard,
  DragOriginal,
  DragPointer,
  DragPointerHovering,
  DragSilhouette,
}

class BlockContext extends InheritedWidget {
  final String id;
  final BlockRenderMode mode;
  final bool isRoot;

  const BlockContext({
    Key key,
    @required this.id,
    @required this.mode,
    @required this.isRoot,
    @required Widget child,
  })  : assert(id != null),
        assert(mode != null),
        assert(isRoot != null),
        assert(child != null),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(BlockContext old) => mode != old.mode || id != old.id;

  static BlockContext of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(BlockContext) as BlockContext;
  }
}
