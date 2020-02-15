import 'package:flutter/cupertino.dart';
import 'package:flutter_app/data_source.dart';
import 'package:flutter_app/entities.dart';
import 'package:observable_ui/core2.dart';



class MomentsModel {
  ListenableList<Moment> moments = ListenableList(initValue: MOMENTS);

  ValueNotifier<bool> showCommentEdit = ValueNotifier(false);
}
