import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/rapid_positioning.dart';

class TestPage extends StatelessWidget {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 100,
        color: Colors.orange,
        child: RapidPositioning(),
      ),
    ));
  }
}

class AnimationTest extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AnimationState();
  }
}

class AnimationState extends State<AnimationTest> {
  bool change = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(seconds: 8),
      decoration: change
          ? BoxDecoration(
              color: Color(0xff115599),
              borderRadius: BorderRadius.all(Radius.circular(5)))
          : BoxDecoration(
              color: Color(0xff990099),
              borderRadius: BorderRadius.all(Radius.circular(30))),
      curve: Curves.fastOutSlowIn,
      width: change ? 100 : 200,
      height: change ? 100 : 200,
      child: FlatButton(
        child: Text("change"),
        onPressed: () {
          setState(() {
            change = !change;
          });
        },
      ),
    );
  }
}
