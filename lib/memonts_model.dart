import 'package:flutter/cupertino.dart';
import 'package:flutter_app/data_source.dart';
import 'package:flutter_app/entities.dart';
import 'package:observable_ui/core2.dart';

const DEFAULT_FRIENDS = [
  Friend(
      name: "梁朝伟",
      avatar:
          "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1575338510&di=2c4ccaf42a260b8463d8744ff1184da1&imgtype=jpg&er=1&src=http%3A%2F%2Fy2.ifengimg.com%2Fa13eecb1dba8cce3%2F2014%2F0925%2Frdn_542371e0404c5.png"),
  Friend(
      name: "刘德华",
      avatar:
          "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1575338736&di=59553e505a6fd221c24ae06c4629506e&imgtype=jpg&er=1&src=http%3A%2F%2Fimg.ifeng.com%2Fres%2F200811%2F1126_500745.jpg")
];

class MomentsModel {
  ListenableList<Moment> moments = ListenableList(initValue: MOMENTS);

  ValueNotifier<bool> showCommentEdit = ValueNotifier(false);
}
