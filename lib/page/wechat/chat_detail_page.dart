import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_app/data_source.dart';
import 'package:flutter_app/photo_preview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:observable_ui/core2.dart';
import 'package:observable_ui/provider.dart';
import 'package:observable_ui/widgets2.dart';

import '../../app_model.dart';
import '../../chat_model.dart';
import '../../entities.dart';

class ChatDetailPage extends StatefulWidget {
  ChatDetailPage({Key key}) : super(key: key);

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final model = ViewModelProvider.of<ChatModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(model.friend.name),
      ),
      body: Stack(children: <Widget>[
        Center(
            child: Column(
          children: <Widget>[
            Expanded(child: DialoguePanel()),
            ControlPanel(),
          ],
        )),
        Center(
            child: ListenableBridge(
          data: [model.recording],
          childBuilder: (context) {
            return Visibility(
              child: SoundRecordingIndicator(),
              visible: model.recording.value,
            );
          },
        ))
      ]),
    );
  }
}

class DialoguePanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var chatModel = ViewModelProvider.of<ChatModel>(context);
    return Container(
      color: Color(0xfff1f1f1),
      padding: EdgeInsets.only(left: 16, right: 16),
      child: ListViewEx.builder(
          items: chatModel.msgList,
          primary: false,
          controller: chatModel.dialogueScrollControl,
          itemBuilder: (context, item) {
            Widget itemWidget;
            if (item is Message) {
              switch (item.type) {
                case 0:
                  itemWidget = MessageBox(
                    message: item,
                    child: _buildTextBox(context, item),
                  );
                  break;
                case 1:
                  itemWidget = MessageBox(
                    message: item,
                    child: _buildImageBox(context, item),
                  );
                  break;
                case 2:
                  itemWidget = MessageBox(
                    message: item,
                    child: _buildSoundBox(context, item),
                  );
                  break;
                default:
                  itemWidget = Text("暂不支持此类型消息");
                  break;
              }
            } else if (item is Marker) {
              switch (item.type) {
                case 0:
                  itemWidget = TimeMarker(item);
                  break;
                default:
                  itemWidget = Text("暂不支持此类型消息");
                  break;
              }
            } else {
              itemWidget = Text("暂不支持此类型消息");
            }

            return Padding(
                child: GestureDetector(
                  child: itemWidget,
                  onLongPressStart: (details) {
                    print(details.globalPosition);
                    print(details.localPosition);
                    showMenu(
                        context: context,
                        position: RelativeRect.fromLTRB(
                            -details.globalPosition.dx,
                            details.globalPosition.dy,
                            0,
                            0),
                        items: [
                          PopupMenuItem(
                            value: "删除",
                            child: Text("删除"),
                          ),
                          PopupMenuItem(
                            value: "复制",
                            child: Text("复制"),
                          )
                        ]).then((v) {
                      if ("删除" == v) {
                        chatModel.msgList.remove(item);
                      }
                    });
                  },
                ),
                padding: EdgeInsets.only(top: 10, bottom: 10));
          }),
    );
  }
}

class SoundRecordingIndicator extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SoundRecordingIndicator();
  }
}

class _SoundRecordingIndicator extends State<SoundRecordingIndicator> {
  @override
  Widget build(BuildContext context) {
    final model = ViewModelProvider.of<ChatModel>(context);
    return SizedBox(
      width: 200,
      height: 200,
      child: Container(
          decoration: BoxDecoration(
              color: Color(0xaa000000),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.keyboard_voice,
                size: 60,
              ),
              SizedBox(
                width: 50,
                height: 60,
                child: CustomPaint(
                  painter: VoiceIndicator(model.voiceLevel),
                  size: Size(60, 80),
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          )),
    );
  }
}

class VoiceIndicator extends CustomPainter {
  final ValueNotifier<int> repaint;

  final Paint p = Paint();

  VoiceIndicator(this.repaint) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    var level = min(this.repaint.value, 7);
    p.color = Color(0xFFbdbdbd);
    var h = size.height / 15;
    var maxW = size.width;
    var minW = maxW / 8;
    for (int i = 0; i <= level; i++) {
      canvas.drawRect(
          Rect.fromLTRB(0, i * h * 2, (8 - i) * minW, i * h * 2 + h), p);
    }
    p.color = Color(0xFF000000);
    for (int i = level + 1; i <= 7; i++) {
      canvas.drawRect(
          Rect.fromLTRB(0, i * h * 2, (8 - i) * minW, i * h * 2 + h), p);
    }
  }

  @override
  SemanticsBuilderCallback get semanticsBuilder {
    return (Size size) {
      var rect = Offset.zero & size;
      var width = size.shortestSide * 0.4;
      rect = const Alignment(0.8, -0.9).inscribe(Size(width, width), rect);
      return [
        CustomPainterSemantics(
          rect: rect,
          properties: SemanticsProperties(
            label: 'Sun',
            textDirection: TextDirection.ltr,
          ),
        ),
      ];
    };
  }

  @override
  bool shouldRepaint(VoiceIndicator oldDelegate) {
    return repaint.value != oldDelegate.repaint.value;
  }
}

class ControlPanel extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ControlPanelState();
  }
}

class ControlPanelState extends State {
  bool _panelVisible = false;

  //false :录音  true :文本输入
  bool _inputMode = false;

  String _inputText = "";

  TextEditingController _textEditingController = TextEditingController();

  bool _recording = false;

  _startRecording(ChatModel model, AppModel appModel) async {
    model.recordUri = await appModel.recorder.startRecorder(null);
    model.recording.value = !model.recording.value;

    print('startRecorder: ${model.recordUri}');
    model.recorderSubscription =
        appModel.recorder.onRecorderStateChanged.listen((e) {
      model.duration = e.currentPosition.toInt();
      model.voiceLevel.value = Random().nextInt(7);
    });
    setState(() {
      _recording = true;
    });
  }

  _stopRecording(ChatModel model, AppModel appModel) async {
    String result = await appModel.recorder.stopRecorder();
    print('stopRecorder: $result');
    if (model.recorderSubscription != null) {
      model.recorderSubscription.cancel();
      model.recorderSubscription = null;
    }
    if (model.recordUri == null || model.recordUri.length <= 0) {
      return;
    }
    model.msgList.add(Message(2,
        url: model.recordUri, duration: model.duration, sender: USER));
    model.recordUri = null;
    model.duration = 0;
    model.recording.value = !model.recording.value;
    setState(() {
      _recording = false;
    });
  }

  _sendTextMessage(ChatModel model, String text) {
    model.msgList.add(Marker(0, DateTime.now().toString()));
    model.msgList.add(Message(0, text: text, sender: USER));
    setState(() {
      _textEditingController.text = "";
      _inputText = "";
    });
    model.dialogueScrollControl.jumpTo((model.msgList.length * 60).toDouble());
  }

  @override
  Widget build(BuildContext context) {
    final model = ViewModelProvider.of<ChatModel>(context);
    final appModel = ViewModelProvider.of<AppModel>(context);

    return WillPopScope(
        onWillPop: () {
          if (_panelVisible) {
            setState(() {
              _panelVisible = false;
            });
            return Future.value(false);
          }
          return Future.value(true);
        },
        child: Container(
          color: Color.fromARGB(255, 247, 247, 247),
          child: Column(
            children: <Widget>[
              Padding(
                child: Row(
                  children: <Widget>[
                    Exchange(
                        child1: GestureDetector(
                          child: Icon(
                            Icons.keyboard_voice,
                            size: 30,
                          ),
                          onTap: () {
                            setState(() {
                              _inputMode = !_inputMode;
                              _panelVisible = false;
                            });
                          },
                        ),
                        child2: GestureDetector(
                          child: Icon(
                            Icons.keyboard,
                            size: 30,
                          ),
                          onTap: () {
                            setState(() {
                              _inputMode = !_inputMode;
                            });
                          },
                        ),
                        status: _inputMode),
                    SizedBox(
                      width: 2,
                    ),
                    Expanded(
                      child: DecoratedBox(
                        child: Padding(
                            child: _inputMode
                                ? Align(
                                    child: EditableText(
                                      maxLines: 5,
                                      minLines: 1,
                                      focusNode: FocusNode(),
                                      textAlign: TextAlign.start,
                                      backgroundCursorColor: Color(0xff457832),
                                      cursorColor:
                                          Color.fromARGB(255, 87, 189, 105),
                                      style: TextStyle(
                                          color: Color(0xff000000),
                                          fontSize: 16),
                                      controller: _textEditingController,
                                      onChanged: (text) {
                                        setState(() {
                                          _inputText = text;
                                        });
                                      },
                                    ),
                                    alignment: Alignment.centerLeft,
                                  )
                                : Listener(
                                    child: Center(
                                      child: Text(
                                        _recording ? "松开 结束" : "按住 说话",
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ),
                                    onPointerDown: (details) async {
                                      _startRecording(model, appModel);
                                    },
                                    onPointerUp: (details) async {
                                      _stopRecording(model, appModel);
                                    }),
                            padding: EdgeInsets.all(8)),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(2)),
                            color: _recording
                                ? Color.fromARGB(255, 160, 160, 160)
                                : Colors.white),
                      ),
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Exchange(
                      status: _inputMode,
                      child1: GestureDetector(
                        child: Icon(
                          Icons.insert_emoticon,
                          size: 30,
                        ),
                        onTap: () {},
                      ),
                      child2: GestureDetector(
                        child: Icon(
                          Icons.keyboard,
                        ),
                        onTap: () {},
                      ),
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      child: _inputMode && _inputText.length > 0
                          ? RawMaterialButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(2))),
                              constraints: BoxConstraints(
                                  minWidth: 60.0, minHeight: 30.0),
                              padding: EdgeInsets.all(0),
                              child: Text(
                                "发 送",
                                style: TextStyle(color: Color(0xffffffff)),
                              ),
                              fillColor: Color.fromARGB(255, 87, 189, 105),
                              onPressed: () {
                                FocusScope.of(context).requestFocus();
                                _sendTextMessage(model, _inputText);
                              },
                            )
                          : GestureDetector(
                              child: Icon(
                                Icons.add,
                                size: 30,
                              ),
                              onTap: () {
                                setState(() {
                                  _inputMode = true;
                                  _panelVisible = !_panelVisible;
                                });
                              },
                            ),
                    )
                  ],
                ),
                padding: EdgeInsets.only(top: 5, bottom: 5, left: 4, right: 4),
              ),
              Visibility(
                child: Container(
                    color: Color(0xfff1f1f1),
                    height: 200,
                    child: PageView(children: <Widget>[ToolkitPage()])),
                visible: _panelVisible,
              )
            ],
          ),
        ));
  }
}

class TimeMarker extends StatelessWidget {
  const TimeMarker(this.marker);

  final Marker marker;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Color(0x22aaaaaa),
        padding: EdgeInsets.all(10),
        child: Text(
          marker.text,
          style: TextStyle(fontSize: 10),
        ),
      ),
    );
  }
}

class MessageBox extends StatefulWidget {
  final Message message;

  final Widget child;

  const MessageBox({Key key, this.message, this.child}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MessageBoxState();
  }
}

Widget _buildImageBox(BuildContext context, Message message) {
  return Container(
    margin: EdgeInsets.only(left: 16),
    padding: EdgeInsets.all(10),
    child: PhotoHero(
      width: 100,
      photo: message.file.path,
      onTap: () {
        Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                PhotoPreviewPage(message.file.path),
            opaque: false));
      },
    ),
  );
}

class MessageBoxState extends State<MessageBox> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      child: Row(
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(3)),
                image: DecorationImage(
                    image: NetworkImage(widget.message.sender.avatar),
                    fit: BoxFit.cover)),
          ),
          widget.child
        ],
      ),
      textDirection:
          widget.message.sender == USER ? TextDirection.rtl : TextDirection.ltr,
    );
  }
}

Widget _buildSoundBox(BuildContext context, Message message) {
  final radio = min(max(message.duration.toInt() / (60 * 1000), 0.3), 1);
  final appModel = ViewModelProvider.of<AppModel>(context);

  return Expanded(
      child: FractionallySizedBox(
    alignment: AlignmentDirectional.centerStart,
    widthFactor: radio,
    child: Container(
        margin: EdgeInsetsDirectional.only(start: 10),
        child: RaisedButton(
          color: Color(0xffffffff),
          child: Text(
            "${message.duration.toInt() ~/ 1000}'",
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 16),
          ),
          onPressed: () {
            appModel.recorder.startPlayer(message.url).then((s) {});
          },
        )),
  ));
}

Widget _buildTextBox(BuildContext context, Message message) {
  return Container(
    constraints: BoxConstraints(minWidth: 40, maxWidth: 300),
    margin: EdgeInsetsDirectional.only(start: 10),
    padding: EdgeInsets.all(6),
    color: Color(0xffffffff),
    child: Text(
      message.text,
      softWrap: true,
      style: TextStyle(fontSize: 16),
    ),
  );
}

class ToolkitPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ToolkitPageState();
  }
}

class ToolkitPageState extends State {
  Future sendImageMessage(BuildContext context, ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source);
    if (image != null) {
      ViewModelProvider.of<ChatModel>(context)
          .msgList
          .add(Message(1, file: image, sender: USER));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: Center(
                    child: Column(
              children: <Widget>[
                IconButton(
                    icon: Icon(Icons.image),
                    onPressed: () {
                      sendImageMessage(context, ImageSource.gallery);
                    }),
                Text("相册")
              ],
            ))),
            Expanded(
                child: Center(
                    child: Column(
              children: <Widget>[
                IconButton(
                    icon: Icon(Icons.camera),
                    onPressed: () {
                      sendImageMessage(context, ImageSource.camera);
                    }),
                Text("拍摄")
              ],
            ))),
            Expanded(
                child: Center(
                    child: Column(
              children: <Widget>[
                IconButton(icon: Icon(Icons.attach_file), onPressed: () {}),
                Text("文件")
              ],
            ))),
          ],
        )),
        Expanded(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: Center(
                    child: Column(
              children: <Widget>[
                IconButton(
                    icon: Icon(Icons.account_balance_wallet),
                    onPressed: () {
                      Navigator.of(context).pushNamed("/moments");
                    }),
                Text("红包")
              ],
            ))),
          ],
        ))
      ],
    );
  }
}

class Exchange extends StatelessWidget {
  final Widget child1;

  final Widget child2;

  final bool status;

  const Exchange({Key key, this.child1, this.child2, this.status})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Visibility(
          visible: status,
          child: child1,
        ),
        Visibility(
          visible: !status,
          child: child2,
        )
      ],
    );
  }
}
