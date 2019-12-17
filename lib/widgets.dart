//实现角标
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Subscript extends StatelessWidget {
  final double width;

  final double height;

  final Widget content;

  final Widget subscript;

  const Subscript(
      {Key key, this.width, this.height, this.content, this.subscript})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
            child: this.content,
            width: this.width,
            height: this.height,
            alignment: Alignment.center),
        Container(
            child: this.subscript,
            width: this.width,
            height: this.height,
            alignment: Alignment.topRight)
      ],
    );
  }
}

///跑马灯效果
class MarqueeText extends LeafRenderObjectWidget {
  final double width;

  final double height;

  final String text;

  final TextStyle style;

  const MarqueeText({
    Key key,
    this.text,
    this.width,
    this.height,
    this.style,
  }) : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MarqueeTextRenderObject()
      ..style = style
      ..width = width
      ..height = height
      ..text = text;
  }
}

class MarqueeTextRenderObject extends RenderBox {
  double width;

  double height;

  String text;

  TextStyle style;

  double _dx = 0.0;

  MarqueeTextRenderObject({this.width, this.height, this.text, this.style});

  @override
  void performLayout() {
    size = Size(width, height);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final String newText = text + "    ";
    var textPainter = TextPainter(
        text: TextSpan(text: newText, style: style),
        textDirection: TextDirection.ltr)
      ..layout();

    var count = size.width ~/ textPainter.width + 2;
    String lastText = "";

    for (int i = 1; i <= count; i++) {
      lastText += newText;
    }
    var lastPainter = TextPainter(
        text: TextSpan(text: lastText, style: style),
        textDirection: TextDirection.ltr)
      ..layout();
    print(
        "count:${count} lastPainter.width:${lastPainter.width}  textPainter.width:${textPainter.width}   size.width:${size.width} $_dx");
    context.canvas.save();
    context.canvas.clipRect(Rect.fromLTRB(
        offset.dx, offset.dy, offset.dx + size.width, offset.dy + size.height));
    var newOffset = Offset(offset.dx + _dx, offset.dy);
    lastPainter.paint(context.canvas, newOffset);
    context.canvas.restore();

    if (_dx <= -(lastPainter.width - size.width)) {
      _dx = -((count - 1) * textPainter.width - size.width);
    } else {
      _dx -= 1.0;
    }

    Future.delayed(Duration(milliseconds: 16), () {
      markNeedsPaint();
    });
  }
}

////仅仅识别上下方向滚动
enum VerticalEvent { UP, DOWN }

class VerticalGestureDetector extends StatefulWidget {
  final Widget child;

  final void Function(VerticalEvent event) onEvent;

  VerticalGestureDetector({Key key, this.child, this.onEvent})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return VerticalGestureDetectorState();
  }
}

class VerticalGestureDetectorState extends State<VerticalGestureDetector> {
  PointerEvent startPointEvent;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _handlePointerDown,
      onPointerMove: _handlePointerMove,
      onPointerUp: _handlePointerUp,
      child: widget.child,
    );
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (startPointEvent == null) {
      startPointEvent = event;
      return;
    }
    if ((event.position.dy - startPointEvent.position.dy).abs() < 20) {
      return;
    }

    var arc = atan((event.position.dy - startPointEvent.position.dy).abs() /
        (event.position.dx - startPointEvent.position.dx).abs());
    if (arc > pi / 4) {
      if (event.position.dy > startPointEvent.position.dy) {
        this.widget.onEvent(VerticalEvent.DOWN);
      } else {
        this.widget.onEvent(VerticalEvent.UP);
      }
      startPointEvent = null;
    }
  }

  void _handlePointerDown(PointerDownEvent event) {
    startPointEvent = event;
  }

  void _handlePointerUp(PointerUpEvent event) {
    startPointEvent = null;
  }
}
