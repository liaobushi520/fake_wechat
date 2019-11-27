import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:observable_ui/core2.dart';

import 'entities.dart';

class ChatModel {
  final FlutterSound flutterSound = new FlutterSound();

  final ScrollController dialogueScrollControl = ScrollController();

  StreamSubscription<RecordStatus> recorderSubscription;

  String recordUri;

  ListenableList<Item> msgList = ListenableList();

  ValueNotifier<bool> panelVisible = ValueNotifier(false);

  ///是否正在录音
  ValueNotifier<bool> recording = ValueNotifier(false);

  //false :录音  true :文本输入
  ValueNotifier<bool> inputMode = ValueNotifier(false);

  ValueNotifier<String> inputText = ValueNotifier("");

  ValueNotifier<int> voiceLevel = ValueNotifier(0);

  num duration;
}
