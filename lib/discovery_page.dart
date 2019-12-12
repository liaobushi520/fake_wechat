import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DiscoveryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GestureDetector(
          child: Container(
            child: Row(
              children: <Widget>[
                Icon(Icons.camera),
                SizedBox(
                  width: 8,
                ),
                Text("朋友圈"),
                Spacer(),
                Icon(Icons.chevron_right)
              ],
            ),
            padding: EdgeInsets.all(8),
          ),
          onTap: () {
            Navigator.of(context).pushNamed("/moments");
          },
        ),
      ],
    );
  }
}
