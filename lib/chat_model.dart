import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:observable_ui/core.dart';

import 'entities.dart';

class ChatModel extends ChangeNotifier {
  final FlutterSound flutterSound = new FlutterSound();

  final ScrollController dialogueScrollControl = ScrollController();

  StreamSubscription<RecordStatus> recorderSubscription;

  String recordUri;

  ObservableList<Item> msgList = ObservableList();

  ObservableValue<bool> panelVisible = ObservableValue(false);

  ///是否正在录音
  ObservableValue<bool> recording = ObservableValue(false);

  //false :录音  true :文本输入
  ObservableValue<bool> inputMode = ObservableValue(false);

  ObservableValue<String> inputText = ObservableValue("");

  num duration;
}
