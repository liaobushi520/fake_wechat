import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';

import 'package:observable_ui/core.dart';



class Item {}

class Message implements Item {
  const Message(this.type, {this.file, this.text, this.url, this.duration});

  final int type; //0 文本  1 图片  2 声音 3 红包

  final File file;

  final String text;

  final String url;

  final num duration;
}

class Marker implements Item {
  const Marker(this.type, this.text);

  final int type;

  final String text;
}

class ChatModel extends ChangeNotifier {
  final FlutterSound flutterSound = new FlutterSound();

  StreamSubscription<RecordStatus> recorderSubscription;

  String recordUri;

  ObservableList<Item> msgList = ObservableList();

  ObservableValue<bool> panelVisible = ObservableValue(false);

  ObservableValue<bool> recording = ObservableValue(false);

  ObservableValue<bool> inputMode = ObservableValue(false);

  ObservableValue<String> inputText=ObservableValue("");

  num duration;


}
