import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'block.dart';
import 'block_canvas.dart';
import 'block_target.dart';
import 'fixed_block.dart';

typedef OnRemoved = void Function();

class DraggableBlock extends StatefulWidget {
  final String id;
  final BlockRenderMode mode;
  final bool isRoot;
  final OnRemoved onRemoved;
  final Widget dragPlaceholder;

  DraggableBlock({
    @required this.id,
    @required this.mode,
    @required this.isRoot,
    @required this.onRemoved,
    @required this.dragPlaceholder,
  })  : assert(id != null),
        assert(mode != null),
        assert(isRoot != null),
        assert(onRemoved != null),
        assert(dragPlaceholder != null);

  @override
  _DraggableBlockState createState() => _DraggableBlockState();
}

class _DraggableBlockState extends State<DraggableBlock> {
  GestureRecognizer _recognizer;
  bool _beingDragged;

  @override
  void initState() {
    super.initState();

    _beingDragged = false;
    _recognizer = ImmediateMultiDragGestureRecognizer()..onStart = _startDrag;
  }

  @override
  void dispose() {
    if (!_beingDragged) {
      _recognizer.dispose();
    }

    super.dispose();
  }

  _BlockDrag _startDrag(Offset position) {
    if (_beingDragged) return null;

    var canvas = CanvasContext.of(context);

    final RenderBox renderObject = context.findRenderObject();
    Offset dragStartPoint = renderObject.globalToLocal(position);

    setState(() {
      _beingDragged = true;
    });

    final _BlockDrag drag = _BlockDrag(
      overlayState: Overlay.of(context, debugRequiredFor: widget),
      id: widget.id,
      canvas: canvas,
      initialPosition: position,
      dragStartPoint: dragStartPoint,
      onDragEnd: (Velocity velocity, Offset offset, bool wasAccepted) {
        if (mounted) {
          setState(() {
            _beingDragged = false;
          });
        } else {
          _beingDragged = false;
          _recognizer.dispose();
        }
        if (wasAccepted) widget.onRemoved();
      },
    );

    return drag;
  }

  void _routePointer(PointerEvent event) {
    if (_beingDragged) return;
    _recognizer.addPointer(event);
  }

  @override
  Widget build(BuildContext context) {
    assert(Overlay.of(context, debugRequiredFor: widget) != null);

    return Listener(
      onPointerDown: !_beingDragged ? _routePointer : null,
      child: !_beingDragged
          ? FixedBlock(
              id: widget.id,
              mode: widget.mode,
              isRoot: widget.isRoot,
            )
          : widget.dragPlaceholder,
    );
  }
}

enum _DragEndKind { dropped, canceled }

typedef _OnDragEnd = void Function(
  Velocity velocity,
  Offset offset,
  bool wasAccepted,
);

class _BlockDrag extends Drag {
  _BlockDrag({
    @required this.overlayState,
    @required this.canvas,
    @required this.id,
    Offset initialPosition,
    this.dragStartPoint = Offset.zero,
    this.onDragEnd,
  })  : assert(overlayState != null),
        assert(canvas != null),
        assert(id != null),
        assert(dragStartPoint != null) {
    _entry = OverlayEntry(builder: _build);
    overlayState.insert(_entry);
    _position = initialPosition;
    updateDrag(initialPosition);
  }

  final String id;
  final CanvasContext canvas;

  final Offset dragStartPoint;

  final _OnDragEnd onDragEnd;
  final OverlayState overlayState;

  BlockTargetState _activeTarget;
  final List<BlockTargetState> _enteredTargets = <BlockTargetState>[];
  Offset _position;
  Offset _lastOffset;
  OverlayEntry _entry;

  @override
  void update(DragUpdateDetails details) {
    _position += details.delta;
    updateDrag(_position);
  }

  @override
  void end(DragEndDetails details) {
    finishDrag(_DragEndKind.dropped, details.velocity);
  }

  @override
  void cancel() {
    finishDrag(_DragEndKind.canceled);
  }

  void updateDrag(Offset globalPosition) {
    _lastOffset = globalPosition - dragStartPoint;
    _entry.markNeedsBuild();
    final HitTestResult result = HitTestResult();
    WidgetsBinding.instance.hitTest(result, globalPosition);

    final List<BlockTargetState> targets =
        _getDragTargets(result.path).toList();

    bool listsMatch = false;
    if (targets.length >= _enteredTargets.length &&
        _enteredTargets.isNotEmpty) {
      listsMatch = true;
      final Iterator<BlockTargetState> iterator = targets.iterator;
      for (int i = 0; i < _enteredTargets.length; i += 1) {
        iterator.moveNext();
        if (iterator.current != _enteredTargets[i]) {
          listsMatch = false;
          break;
        }
      }
    }

    // If everything's the same, bail early.
    if (listsMatch) return;

    // Leave old targets.
    _leaveAllEntered();

    // Enter new targets.
    final BlockTargetState newTarget = targets.firstWhere(
      (BlockTargetState target) {
        _enteredTargets.add(target);
        return target.didEnter(id);
      },
      orElse: () => null,
    );

    _activeTarget = newTarget;
  }

  Iterable<BlockTargetState> _getDragTargets(
      Iterable<HitTestEntry> path) sync* {
    for (HitTestEntry entry in path) {
      if (entry.target is RenderMetaData) {
        final RenderMetaData renderMetaData = entry.target;
        if (renderMetaData.metaData is BlockTargetState)
          yield renderMetaData.metaData;
      }
    }
  }

  void _leaveAllEntered() {
    for (int i = 0; i < _enteredTargets.length; i += 1)
      _enteredTargets[i].didLeave(id);
    _enteredTargets.clear();
  }

  void finishDrag(_DragEndKind endKind, [Velocity velocity]) {
    bool wasAccepted = false;
    if (endKind == _DragEndKind.dropped && _activeTarget != null) {
      final RenderBox box = overlayState.context.findRenderObject();
      final Offset overlayTopLeft = box.localToGlobal(Offset.zero);

      wasAccepted = _activeTarget.didDrop(
        id,
        Offset(
          _lastOffset.dx - overlayTopLeft.dx,
          _lastOffset.dy - overlayTopLeft.dy,
        ),
      );
      _enteredTargets.remove(_activeTarget);
    }
    _leaveAllEntered();
    _activeTarget = null;
    _entry.remove();
    _entry = null;
    if (onDragEnd != null)
      onDragEnd(velocity ?? Velocity.zero, _lastOffset, wasAccepted);
  }

  Widget _build(BuildContext context) {
    final RenderBox box = overlayState.context.findRenderObject();
    final Offset overlayTopLeft = box.localToGlobal(Offset.zero);

    var mode = _activeTarget != null && _activeTarget.widget.triggerHover
        ? BlockRenderMode.DragPointerHovering
        : BlockRenderMode.DragPointer;

    return Positioned(
      left: _lastOffset.dx - overlayTopLeft.dx,
      top: _lastOffset.dy - overlayTopLeft.dy,
      child: IgnorePointer(
        child: CanvasContext(
          onBlockMoved: canvas.onBlockMoved,
          blockProvider: canvas.blockProvider,
          rootBlocksProvider: canvas.rootBlocksProvider,
          zoom: canvas.zoom,
          extra: canvas.extra,
          child: FixedBlock(
            id: id,
            mode: mode,
            isRoot: true,
          ),
        ),
      ),
    );
  }
}
