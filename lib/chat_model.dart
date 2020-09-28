import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:observable_ui/core2.dart';

import 'entities.dart';

class ChatModel {
  final Friend friend;

  final ScrollController dialogueScrollControl = ScrollController();

  Stream<RecordingDisposition> recorderSubscription;

  String recordUri;

  ListenableList<Item> msgList = ListenableList();

  ///是否正在录音
  ValueNotifier<bool> recording = ValueNotifier(false);

  //false :录音  true :文本输入

  ValueNotifier<int> voiceLevel = ValueNotifier(0);

  num duration;

  ChatModel(this.friend);
}
