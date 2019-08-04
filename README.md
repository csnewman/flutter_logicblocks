# Flutter Logic Blocks
Flutter logic blocks is a library for creating visual programming editors. The core of the project is collection of helper widgets for handling input and rendering, which is then combined with one of the block styles below.


## Styles


### Modern
![](https://raw.githubusercontent.com/csnewman/flutter_logicblocks/master/imgs/modern.png)

Inspired by the [ScratchBlocks](https://github.com/LLK/scratch-blocks) project. The style is not exactly the same, and nor does it try to be.

Themed text fields and buttons are coming soon.

#### Canvas
```dart
ModernBlockCanvasContext(
  userData: null, // User data that is automatically passed around
  zoom: 1.0, // Currently broken due to some internal flutter issues, keep at 1.0
  offset: Offset(0, 0), // Canvas pan offset
  blockBuilder: _buildBlock, // See bellow
  onBlockMoved: (block, pos) {
    // Callback to handle when a block (given by its id) is moved to a position (canvas relative)
    // You should store this state and use it for the root blocks
  },
  rootBlocksProvider: () {
    // Called to get the list of blocks that need rendering
    // If a block is a child of another, then it should not be returned here

    var blocks = <RootBlock>[];

    /* blocks.add(RootBlock(
      block: Some id,
      position: Canvas relative position,
    )); */

    return blocks;
  },
  child: BlockCanvas(
    background: BlockCanvasBackground(
      onPan: (delta) {
        // Callback to handle canvas pans
      },
    ),
  ),
)
```

#### Block builder
```dart
Widget _buildBlock(BuildContext context, BlockContext blockContext) {
  var userData = ModernBlockCanvasContext.getUserData</* data type */>(context);
  // Use blockContext.id to get state for this block from the userData
  
  // State should store the block type
  
  return /* A custom widget */;
}
```

#### Example widget
```dart
class ExampleBlockWidget extends StatelessWidget {
  final String id;
  final /* Some state type */ data;
  final BlockRenderMode mode;

  ExampleBlockWidget({
    this.id,
    this.data,
    this.mode,
  });

  @override
  Widget build(BuildContext context) {
    var userData = ModernBlockCanvasContext.getUserData</* userData type */>(context);

    return ModernBlock(
      isStartBlock: false, // Whether to have a notch or circle on top
      theme: ModernBlockThemes.orange, // The color of the block background
      nextBlock: data.nextChild, // The block to render after this block, as an id
      nextBlockDropped: (id, pos) {
        // Callback to handle when a new block is dropped onto the end of this block
        return true;
      },
      nextBlockRemoved: () {
        // Callback to handle when the following block is removed
      },
      elements: <ModernBlockElement>[
        MaterialBlockContentElement(
          content: Padding(
            padding: const EdgeInsets.fromLTRB(0, 4, 58, 4),
            child: Text("Example block"),
          ),
        ),
        MaterialBlockChildBlockElement(
          block: data.ifChild,
          blockDropped: (id, pos) {
            return true;
          },
          blockRemoved: () {
          },
        ),
        MaterialBlockContentElement(
          content: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 4),
          ),
        ),
        MaterialBlockChildBlockElement(
            block: data.elseChild,
            blockDropped: (id, pos) {
              return true;
            },
            blockRemoved: () {
            }),
        MaterialBlockContentElement(
          content: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 4),
          ),
        ),
      ],
    );
  }
}
```

### Modern (Horizontal)
Planned, however no set target.

### Material
Planned, however no set target.

### Retro
Coming soon.

## State
Flutter logic blocks makes no assumptions about what state framework you are using. The examples show off using [flutter_bloc](https://pub.dev/packages/flutter_bloc). However any standard state framework should work. If not, please open an issue and I can look at making the needed changes.
