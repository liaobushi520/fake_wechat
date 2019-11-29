import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

const DEFAULT_DATA = [
  '↑',
  '★',
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
  'G',
  'H',
  'I',
  'J',
  'K',
  'L',
  'M',
  'N',
  'O',
  'P',
  'Q',
  'R',
  'S',
  'T',
  'U',
  'V',
  'W',
  'X',
  'Y',
  'Z',
  '#'
];

class SelectedChangeNotification extends Notification {
  final String content;

  final int index;

  final bool reset;

  SelectedChangeNotification(this.reset, {this.content, this.index});
}

typedef HandleEventCallback = void Function(PointerEvent pointerEvent);

/// 类似于微信，纵向的可滑动的字母定位器，放置于可横向滑动的PageView中。
/// 如果不额外处理，在Flutter中会出现一个奇怪现象。字母定位器和PageView都会接受到触摸事件。
/// 为了解决这个问题,我们需要在与PageView的手势竞争中获胜。
class _SimpleGestureRecognizer extends OneSequenceGestureRecognizer {
  _SimpleGestureRecognizer({PointerDeviceKind kind}) : super(kind: kind);

  HandleEventCallback handleEventCallback;

  PointerEvent _initPointerEvent;

  bool _accepted = false;

  @override
  void handleEvent(PointerEvent event) {
    if (event.pointer != _initPointerEvent.pointer) {
      return;
    }

    if (handleEventCallback != null) {
      handleEventCallback(event);
    }

    if (event is PointerMoveEvent && !_accepted) {
      var arc = atan((event.position.dy - _initPointerEvent.position.dy) /
          (event.position.dx - _initPointerEvent.position.dx));
      //down事件之后的第一次move事件 夹角小于45度 ，我们就放弃跟踪手势，因为我们认为是横向移动事件,让其他widget接受事件，比如PageView
      if (arc.abs() < (pi / 4)) {
        resolve(GestureDisposition.rejected);
        stopTrackingPointer(event.pointer);
        _initPointerEvent = null;
        _accepted = false;
        if (handleEventCallback != null) {
          handleEventCallback(PointerCancelEvent());
        }
      } else {
        _accepted = true;
        resolve(GestureDisposition.accepted);
      }
    } else if (event is PointerUpEvent) {
      stopTrackingPointer(event.pointer);
      _initPointerEvent = null;
      _accepted = false;
    }
  }

  @override
  void addAllowedPointer(PointerDownEvent event) {
    _accepted = false;
    if (_initPointerEvent != null) {
      return;
    }
    _initPointerEvent = event;
    startTrackingPointer(event.pointer, event.transform);
  }

  @override
  String get debugDescription => 'simple gesture';

  @override
  void didStopTrackingLastPointer(int pointer) {}
}

class RapidPositioning extends StatefulWidget {
  final Color highlightColor;

  final List<String> data;

  final void Function(String content, int index) onChanged;

  final Color backgroundColor;

  final Color markerBackgroundColor;

  final double markerSize;

  final TextStyle markerTextStyle;

  final TextStyle textStyle;

  final double width;

  RapidPositioning(
      {Key key,
      this.highlightColor = const Color(0xff3367ff),
      this.data = DEFAULT_DATA,
      this.markerSize = 30.0,
      this.onChanged,
      this.textStyle = const TextStyle(color: Color(0xff000000)),
      this.markerTextStyle =
          const TextStyle(color: Color(0xff000000), fontSize: 20),
      this.markerBackgroundColor = const Color(0x66343434),
      this.backgroundColor = const Color(0x00343434),
      this.width = 20.0})
      : super(key: key);

  @override
  State<RapidPositioning> createState() {
    return RapidPositioningState();
  }
}

class RapidPositioningState extends State<RapidPositioning> {
  Map<Type, GestureRecognizerFactory> _gestureRecognizers =
      const <Type, GestureRecognizerFactory>{};

  GlobalKey _rapidPositioningRenderKey = GlobalKey();
  String _lastReportedContent;
  int _lastReportedIndex;

  @override
  void initState() {
    super.initState();
    _gestureRecognizers = <Type, GestureRecognizerFactory>{
      _SimpleGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<_SimpleGestureRecognizer>(
              () => _SimpleGestureRecognizer(),
              (_SimpleGestureRecognizer instance) {
        instance
          ..handleEventCallback = (e) {
            (_rapidPositioningRenderKey.currentContext.findRenderObject()
                    as RapidPositioningRenderObject)
                .onHandleEvent(e);
          };
      }),
    };
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<SelectedChangeNotification>(
      onNotification: (notification) {
        if (notification.reset) {
          _lastReportedIndex = null;
          _lastReportedContent = null;
          return true;
        }

        if (notification.index != _lastReportedIndex &&
            notification.content != _lastReportedContent) {
          _lastReportedIndex = notification.index;
          _lastReportedContent = notification.content;
          this.widget.onChanged(_lastReportedContent, _lastReportedIndex);
        }
        return true;
      },
      child: RawGestureDetector(
        gestures: _gestureRecognizers,
        behavior: HitTestBehavior.opaque,
        child: RapidPositioningRenderWidget(
          key: _rapidPositioningRenderKey,
          highlightColor: this.widget.highlightColor,
          backgroundColor: this.widget.backgroundColor,
          markerBackgroundColor: this.widget.markerBackgroundColor,
          markerSize: this.widget.markerSize,
          markerTextStyle: this.widget.markerTextStyle,
          data: this.widget.data,
          textStyle: this.widget.textStyle,
        ),
      ),
    );
  }
}

class RapidPositioningRenderWidget extends LeafRenderObjectWidget {
  final Color highlightColor;

  final List<String> data;

  final void Function(String text) onChanged;

  final Color backgroundColor;

  final Color markerBackgroundColor;

  final double markerSize;

  final TextStyle markerTextStyle;

  final TextStyle textStyle;

  final double width;

  RapidPositioningRenderWidget(
      {Key key,
      this.highlightColor = const Color(0xff3367ff),
      this.data = DEFAULT_DATA,
      this.markerSize = 30.0,
      this.onChanged,
      this.textStyle = const TextStyle(color: Color(0xff000000)),
      this.markerTextStyle =
          const TextStyle(color: Color(0xff000000), fontSize: 20),
      this.markerBackgroundColor = const Color(0x66343434),
      this.backgroundColor = const Color(0x00343434),
      this.width = 20.0})
      : super(key: key);

  @override
  LeafRenderObjectElement createElement() {
    return LeafRenderObjectElement(this);
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RapidPositioningRenderObject()
      .._markerSize = this.markerSize
      .._data = this.data
      .._highlightColor = this.highlightColor
      .._markerBackgroundColor = this.markerBackgroundColor
      .._textStyle = this.textStyle
      .._markerTextStyle = this.markerTextStyle
      .._backgroundColor = this.backgroundColor
      .._buildContext = context;
  }
}

class RapidPositioningRenderObject extends RenderBox {
  RapidPositioningRenderObject(
      {List<String> data,
      Color markerBackgroundColor,
      Color highlightColor,
      Color markerTextColor,
      Color backgroundColor,
      double markerSize,
      TextStyle markerTextStyle,
      double width,
      TextStyle textStyle,
      BuildContext context})
      : _markerBackgroundColor = markerBackgroundColor,
        _highlightColor = highlightColor,
        _data = data,
        _markerSize = markerSize,
        _markerTextStyle = markerTextStyle,
        _backgroundColor = backgroundColor,
        _textStyle = textStyle,
        _width = width,
        _buildContext = context;

  PointerEvent _currentEvent;

  BuildContext _buildContext;

  Paint _circlePaint = Paint();

  Paint _markerPaint = Paint();

  Paint _backgroundPaint = Paint();

  Color _markerBackgroundColor;

  Color _backgroundColor;

  Color _highlightColor;

  double _markerSize;

  TextStyle _markerTextStyle;

  TextStyle _textStyle;

  double _width;

  List<String> get data => _data;

  List<String> _data;

  set data(List<String> newData) {
    assert(newData != null);
    if (_data != newData) {
      _data = newData;
      markNeedsPaint();
    }
  }

  @override
  void performLayout() {
    size = Size(_width, constraints.maxHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);

    var charHeight = size.height / data.length;
    var charWidth = size.width;
    var circleSize = min(charWidth, charHeight);

    var highlightPos = -1;
    if (_currentEvent != null && !(_currentEvent is PointerCancelEvent)) {
      if (_currentEvent is PointerUpEvent) {
        highlightPos = -1;
        _currentEvent = null;
        SelectedChangeNotification(true).dispatch(_buildContext);
      } else {
        highlightPos = (_currentEvent.localPosition.dy ~/ charHeight)
            .clamp(0, data.length - 1);
      }
    }

    context.canvas.save();
    context.canvas.translate(offset.dx, offset.dy);

    _backgroundPaint.color = _backgroundColor;
    context.canvas.drawRect(
        Rect.fromLTRB(0, 0, size.width, size.height), _backgroundPaint);

    for (num i = 0; i < _data.length; i++) {
      if (highlightPos >= 0) {
        _circlePaint.color = _highlightColor;
        context.canvas.drawCircle(
            Offset(charWidth / 2, (highlightPos + 0.5) * charHeight),
            circleSize / 2,
            _circlePaint);
      }

      var textPainter = TextPainter(
          text: TextSpan(text: DEFAULT_DATA[i], style: _textStyle),
          textDirection: TextDirection.ltr)
        ..layout();
      textPainter.paint(context.canvas,
          Offset((charWidth - textPainter.width) / 2, charHeight * i));
    }
    context.canvas.restore();

    // draw marker
    if (highlightPos >= 0) {
      context.canvas.save();
      var path = Path();
      var radius = _markerSize;
      context.canvas.translate(offset.dx - radius * 2.5,
          offset.dy + (highlightPos + 0.5) * charHeight - radius);
      path.addArc(
          Rect.fromLTRB(0, 0, radius * 2, radius * 2), pi / 4, pi * 3 / 2);
      path.lineTo(radius + sqrt(2) * radius, radius);
      path.close();

      _markerPaint.color = _markerBackgroundColor;
      context.canvas.drawPath(path, _markerPaint);
      var textPainter = TextPainter(
          text: TextSpan(
              text: DEFAULT_DATA[highlightPos], style: _markerTextStyle),
          textDirection: TextDirection.ltr)
        ..layout();
      textPainter.paint(
          context.canvas,
          Offset(
              radius - textPainter.width / 2, radius - textPainter.height / 2));
      context.canvas.restore();

      SelectedChangeNotification(false,
              content: data[highlightPos], index: highlightPos)
          .dispatch(_buildContext);
    }
  }

  void onHandleEvent(PointerEvent event) {
    if (event is PointerDownEvent ||
        event is PointerMoveEvent ||
        event is PointerUpEvent ||
        event is PointerCancelEvent) {
      _currentEvent = event;
      markNeedsPaint();
    }
  }
}
