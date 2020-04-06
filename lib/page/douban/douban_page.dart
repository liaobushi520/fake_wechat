import 'package:flutter/material.dart';

class DoubanPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DoubanPageState();
  }
}

class Star extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Icon(Icons.star);
  }
}

class DoubanPageState extends State {
  Widget _buildHotItem() {
    return Column(
      children: <Widget>[
        Stack(children: <Widget>[
          Image.network("https://img9.doubanio.com/view/photo/l/public/p2580665456.webp"),

        ],),
        Text("小妇人"),
        Row(
          children: <Widget>[
            Star(),
            Star(),
            Star(),
            Star(),
            Text("8.1"),
          ],
        ),
      ],
    );
  }

  Widget _buildHotBoard() {
  return  GridView.count(
      crossAxisCount: 3,
      children: <Widget>[_buildHotItem(),_buildHotItem(),_buildHotItem()],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildHotBoard(),);
  }
}
