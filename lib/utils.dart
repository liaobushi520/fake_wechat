import 'package:flutter/material.dart';
import 'package:flutter_app/entities.dart';
import 'package:flutter_app/video_feed.dart';

const AVATAR = const <String>[
  "https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=1236308033,3321919462&fm=26&gp=0.jpg",
  "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1575338510&di=2c4ccaf42a260b8463d8744ff1184da1&imgtype=jpg&er=1&src=http%3A%2F%2Fy2.ifengimg.com%2Fa13eecb1dba8cce3%2F2014%2F0925%2Frdn_542371e0404c5.png",
  "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1575338736&di=59553e505a6fd221c24ae06c4629506e&imgtype=jpg&er=1&src=http%3A%2F%2Fimg.ifeng.com%2Fres%2F200811%2F1126_500745.jpg",
  "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1576472833976&di=bfc3b95448eb89321f4e25ea0fbf2054&imgtype=0&src=http%3A%2F%2Fhbimg.huabanimg.com%2Ff2b2ad85a548a22049f10f90cf32dd8cd9f79b0c90c0-gbkg5j_fw658"
];

final MIN_PROGRAMS = [
  MinProgram("抖音", AVATAR[3], (context, item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoFeedPage(),
      ),
    );
  }),
  MinProgram("搞笑趣图", AVATAR[0], (context, item) {}),
  MinProgram("搞笑趣图", AVATAR[0], (context, item) {}),
  MinProgram("搞笑趣图", AVATAR[0], (context, item) {}),
  MinProgram("搞笑趣图", AVATAR[0], (context, item) {}),
  MinProgram("搞笑趣图", AVATAR[0], (context, item) {}),
  MinProgram("搞笑趣图", AVATAR[0], (context, item) {}),
  MinProgram("搞笑趣图", AVATAR[0], (context, item) {}),
  MinProgram("搞笑趣图", AVATAR[0], (context, item) {}),
  MinProgram("搞笑趣图", AVATAR[0], (context, item) {}),
  MinProgram("搞笑趣图", AVATAR[0], (context, item) {}),
  MinProgram("搞笑趣图", AVATAR[0], (context, item) {}),
  MinProgram("搞笑趣图", AVATAR[0], (context, item) {}),
  MinProgram("环球时报", AVATAR[1], (context, item) {}),
  MinProgram("环球时报", AVATAR[0], (context, item) {}),
  MinProgram("搞笑趣图", AVATAR[0], (context, item) {})
];

const colors = [Colors.orange, Colors.red, Colors.blue, Colors.white];

bool isNullOrEmpty<T>(List<T> list) {
  return list == null || list.isEmpty;
}

//11:22:08
String formatHHmmSS(double time) {
  if (time < 0) {
    return "--:--:--";
  }

  int hour = time ~/ 3600;
  String s;
  if (hour < 10) {
    s = "0$hour:";
  } else {
    s = "$hour:";
  }
  int minute = (time - (hour * 3600)) ~/ 60;
  if (minute < 10) {
    s += "0$minute:";
  } else {
    s += "$minute:";
  }
  var second = ((time - hour * 3600 - minute * 60) % 60).toInt();
  if (second < 10) {
    s += "0$second";
  } else {
    s += "$second";
  }
  return s;
}
