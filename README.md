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

### Modern (Horizontal)
Planned, however no set target.

### Material
Planned, however no set target.

### Retro
Coming soon.

## State
Flutter logic blocks makes no assumptions about what state framework you are using. The examples show off using [flutter_bloc](https://pub.dev/packages/flutter_bloc). However any standard state framework should work. If not, please open an issue and I can look at making the needed changes.
