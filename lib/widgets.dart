//实现角标
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:palette_generator/palette_generator.dart';

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

///圆形图片

Widget buildCircleImage(double size, ImageProvider provider) {
  return SizedBox(
    width: size,
    height: size,
    child: DecoratedBox(
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(image: provider, fit: BoxFit.cover)),
    ),
  );
}

Widget buildCircleImage2(double size, ImageProvider provider) {
  return ClipOval(
      child: Image(
    image: provider,
    width: size,
    height: size,
    fit: BoxFit.cover,
  ));
}

///颜色析取
class PalettePanel extends StatelessWidget {
  final PaletteGenerator paletteGenerator;

  const PalettePanel({Key key, this.paletteGenerator}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ListView(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 20,
                height: 20,
                color: paletteGenerator.lightMutedColor?.color,
              ),
              Text(
                "lightMuted",
                style: TextStyle(
                    color: paletteGenerator.lightMutedColor?.titleTextColor,
                    fontSize: 20),
              ),
              SizedBox(
                width: 4,
              ),
              Text(
                "lightMuted",
                style: TextStyle(
                    color: paletteGenerator.lightMutedColor?.bodyTextColor,
                    fontSize: 16),
              )
            ],
          ),
          Row(
            children: <Widget>[
              Container(
                width: 20,
                height: 20,
                color: paletteGenerator.lightVibrantColor?.color,
              ),
              Text(
                "lightVibrant",
                style: TextStyle(
                    color: paletteGenerator.lightVibrantColor?.titleTextColor,
                    fontSize: 20),
              ),
              SizedBox(
                width: 4,
              ),
              Text(
                "lightMuted",
                style: TextStyle(
                    color: paletteGenerator.lightVibrantColor?.bodyTextColor,
                    fontSize: 16),
              )
            ],
          ),
          Row(
            children: <Widget>[
              Container(
                width: 20,
                height: 20,
                color: paletteGenerator.darkMutedColor?.color,
              ),
              Text(
                "darkMutedColor",
                style: TextStyle(
                    color: paletteGenerator.lightMutedColor?.titleTextColor,
                    fontSize: 20),
              ),
              SizedBox(
                width: 4,
              ),
              Text(
                "darkMutedColor",
                style: TextStyle(
                    color: paletteGenerator.darkMutedColor?.bodyTextColor,
                    fontSize: 16),
              )
            ],
          ),
          Row(
            children: <Widget>[
              Container(
                width: 20,
                height: 20,
                color: paletteGenerator.darkVibrantColor?.color,
              ),
              Text(
                "darkVibrant",
                style: TextStyle(
                    color: paletteGenerator.darkVibrantColor?.titleTextColor,
                    fontSize: 20),
              ),
              SizedBox(
                width: 4,
              ),
              Text(
                "darkVibrant",
                style: TextStyle(
                    color: paletteGenerator.darkVibrantColor?.bodyTextColor,
                    fontSize: 16),
              )
            ],
          ),
          Row(
            children: <Widget>[
              Container(
                width: 20,
                height: 20,
                color: paletteGenerator.dominantColor?.color,
              ),
              Text(
                "dominant",
                style: TextStyle(
                    color: paletteGenerator.dominantColor?.titleTextColor,
                    fontSize: 20),
              ),
              SizedBox(
                width: 4,
              ),
              Text(
                "dominant",
                style: TextStyle(
                    color: paletteGenerator.dominantColor?.bodyTextColor,
                    fontSize: 16),
              )
            ],
          ),
          Row(
            children: <Widget>[
              Container(
                width: 20,
                height: 20,
                color: paletteGenerator.mutedColor?.color,
              ),
              Text(
                "muted",
                style: TextStyle(
                    color: paletteGenerator.mutedColor?.titleTextColor,
                    fontSize: 20),
              ),
              SizedBox(
                width: 4,
              ),
              Text(
                "muted",
                style: TextStyle(
                    color: paletteGenerator.mutedColor?.bodyTextColor,
                    fontSize: 16),
              )
            ],
          ),
          Row(
            children: <Widget>[
              Container(
                width: 20,
                height: 20,
                color: paletteGenerator.vibrantColor?.color,
              ),
              Text(
                "vibrant",
                style: TextStyle(
                    color: paletteGenerator.vibrantColor?.titleTextColor,
                    fontSize: 20),
              ),
              SizedBox(
                width: 4,
              ),
              Text(
                "vibrant",
                style: TextStyle(
                    color: paletteGenerator.vibrantColor?.bodyTextColor,
                    fontSize: 16),
              )
            ],
          ),
        ],
      ),
    );
  }
}
