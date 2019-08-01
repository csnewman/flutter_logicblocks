import 'dart:ui';

import 'constants.dart';

class ModernBlockPathBuilder {
  final Path path;
  final bool circleTop;

  ModernBlockPathBuilder({
    this.circleTop,
  })  : path = Path(),
        assert(circleTop != null);

  void createNotch(Path path, double x, double y, double width, double height,
      double radius, bool xFlip) {
    var hradius = radius / 2;

    var xradius = xFlip ? -radius : radius;
    var hxradius = xradius / 2;
    var xslope = xFlip ? -height : height;

    if (xFlip) {
      x += width;
      width = -(width + (xradius * 2) + (xslope * 2));
    } else {
      width = width - (xradius * 2) - (xslope * 2);
    }

    x += xradius;

    path.lineTo(x - xradius, y);
    path.cubicTo(x, y, x + hxradius, y + hradius, x + xradius, y + radius);

    x += xslope;
    y += height;

    path.lineTo(x - xradius, y - radius);
    path.cubicTo(x - hxradius, y - hradius, x, y, x + xradius, y);

    x += width;

    path.lineTo(x - xradius, y);
    path.cubicTo(x, y, x + hxradius, y - hradius, x + xradius, y - radius);

    x += xslope;
    y -= height;

    path.lineTo(x - xradius, y + radius);
    path.cubicTo(x - hxradius, y + hradius, x, y, x + xradius, y);
  }

  double colWidth = 10;
  double radius = notchRadius;
  double notchOffset = 10;

  double lastY;

  void start() {
    if (circleTop){
      path.moveTo(0, entryCircleHeight);
    }else {
      path.moveTo(radius, 0);
      path.lineTo(colWidth, 0);
    }
    lastY = 0;
  }

  void addBlock(double yOff, Size size, bool isFirst, bool isLast) {
//    assert(lastY == yOff);

    if (circleTop && isFirst) {
      yOff += entryCircleHeight;
      size = Size(size.width, size.height - entryCircleHeight);
      path.quadraticBezierTo(entryCircleWidth / 2, - entryCircleHeight, entryCircleWidth, entryCircleHeight);
    } else {
      if (isFirst) {
        path.lineTo(colWidth, yOff);
      } else {
        path.lineTo(colWidth, yOff - radius);
        path.quadraticBezierTo(colWidth, yOff, colWidth + radius, yOff);
      }

      createNotch(path, notchOffset + (isFirst ? 0 : colWidth), yOff,
          notchWidth, notchHeight, radius, false);
    }

    path.lineTo(size.width - radius, yOff);
    path.quadraticBezierTo(size.width, yOff, size.width, yOff + radius);

    path.lineTo(size.width, yOff + size.height - notchHeight - radius);
    path.quadraticBezierTo(size.width, yOff + size.height - notchHeight,
        size.width - radius, yOff + size.height - notchHeight);

    createNotch(
        path,
        notchOffset + (isLast ? 0 : colWidth),
        yOff + size.height - notchHeight,
        notchWidth,
        notchHeight,
        radius,
        true);

    lastY = yOff + size.height - notchHeight;

    if (isLast) {
      path.lineTo(colWidth, lastY);
    } else {
      path.lineTo(colWidth + radius, lastY);
      path.quadraticBezierTo(colWidth, lastY, colWidth, lastY + radius);
//      lastY += radius;
    }
  }

  void end() {
    path.lineTo(radius, lastY);
    path.quadraticBezierTo(0, lastY, 0, lastY - radius);

    if (circleTop){
      path.lineTo(0, entryCircleHeight);
    }else {
      path.lineTo(0, radius);
      path.quadraticBezierTo(0, 0, radius, 0);
    }
  }
}
