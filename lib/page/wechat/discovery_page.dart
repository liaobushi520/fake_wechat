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
    return Container(
      color: Color(0xfff1f1f1),
      child: Column(
        children: <Widget>[
          GestureDetector(
            child: Container(
              child: Row(
                children: <Widget>[
                  Icon(Icons.camera),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    "朋友圈",
                    style: TextStyle(fontSize: 16),
                  ),
                  Spacer(),
                  Icon(
                    Icons.chevron_right,
                    color: Color(0xffbdbdbd),
                  )
                ],
              ),
              padding: EdgeInsets.all(14),
              color: Colors.white,
            ),
            onTap: () {
              Navigator.of(context).pushNamed("/moments");
            },
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
