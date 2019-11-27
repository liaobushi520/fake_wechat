import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

////1:先要把数字画出来

class RapidPositioning extends LeafRenderObjectWidget {
  @override
  LeafRenderObjectElement createElement() {
    return LeafRenderObjectElement(this);
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RapidPositioningRenderObject();
  }
}

class RapidPositioningRenderObject extends RenderBox {
  @override
  void performLayout() {
    size = Size(200, 100);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    TextPainter(text: TextSpan(text: "A"), textDirection: TextDirection.ltr)
      ..layout()
      ..paint(context.canvas, offset);

    var path = Path();

    /// pi

    path.addArc(Rect.fromLTRB(0, 0, 100, 100), 3.14 / 4, 3.14 * 3 / 2);
//    path.addOval(Rect.fromLTRB(0, 0, 100, 100));
//    path.moveTo(0, 0);
//    path.lineTo(0, 100);
//    path.lineTo(100, 100);
    path.close();

    var p = Paint();
    p.color = Color(0xffbbd908);

    context.canvas.save();
    context.canvas.translate(offset.dx, offset.dy);
    context.canvas.drawPath(path, p);
    context.canvas.restore();
  }

  @override
  void handleEvent(PointerEvent event, covariant HitTestEntry entry) {
    super.handleEvent(event, entry);

    if (event is PointerDownEvent) {
      print(event.position.toString());
      markNeedsPaint();
    }
  }

  @override
  bool hitTestSelf(Offset position) {
    return true;
  }
}
