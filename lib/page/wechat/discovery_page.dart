import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DiscoveryPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DiscoveryPageState();
  }
}

class DiscoveryPageState extends State<DiscoveryPage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
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

  @override
  bool get wantKeepAlive => true;
}
