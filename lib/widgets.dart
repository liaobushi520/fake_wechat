//实现角标
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
