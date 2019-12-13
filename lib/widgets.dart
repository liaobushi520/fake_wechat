//实现角标
import 'dart:math';

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
