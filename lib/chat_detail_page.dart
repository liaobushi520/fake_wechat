import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_app/photo_preview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:observable_ui/core2.dart';
import 'package:observable_ui/provider.dart';
import 'package:observable_ui/widgets2.dart';

import 'app_model.dart';
import 'chat_model.dart';
import 'entities.dart';

class ChatDetailPage extends StatefulWidget {
  ChatDetailPage({Key key, this.title}) : super(key: key);

  final String title;

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
        title: Text(widget.title),
      ),
      body: WillPopScope(
          onWillPop: () {
            if (model.panelVisible.value) {
              model.panelVisible.value = false;
              return Future.value(false);
            }
            return Future.value(true);
          },
          child: Stack(children: <Widget>[
            Center(
                child: Column(
              children: <Widget>[
                Expanded(child: DialoguePanel()),
                ControlPanel(),
                ListenableBridge(
                  data: [model.panelVisible],
                  childBuilder: (context) {
                    return Visibility(
                      child: ToolkitPanel(),
                      visible: model.panelVisible.value,
                    );
                  },
                )
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
          ])),
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
            StatelessWidget itemWidget;
            if (item is Message) {
              switch (item.type) {
                case 0:
                  itemWidget = TextMessage(item);
                  break;
                case 1:
                  itemWidget = ImageMessage(item);
                  break;
                case 2:
                  itemWidget = SoundMessage(item);
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

            return Dismissible(
              key: ValueKey(item),
              child: Padding(
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
                  padding: EdgeInsets.only(top: 10, bottom: 10)),
              onDismissed: (direction) {
                chatModel.msgList.remove(item);
              },
            );
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

class InputModeTransformation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = ViewModelProvider.of<ChatModel>(context);

    final appModel = ViewModelProvider.of<AppModel>(context);

    return ExchangeEx(
        child1: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(
                color: Color(0xffbdbdbd),
                width: 1.0,
              ),
            ),
            alignment: Alignment.centerLeft,
            child: EditableTextEx(
              data: model.inputText,
              child: EditableText(
                maxLines: 5,
                minLines: 1,
                focusNode: FocusNode(),
                textAlign: TextAlign.start,
                backgroundCursorColor: Color(0xff457832),
                cursorColor: Color(0xff246786),
                style: TextStyle(color: Color(0xff000000)),
                controller: TextEditingController(),
              ),
            )),
        child2: GestureDetector(
            onLongPressStart: (details) async {
              model.recordUri = await appModel.recorder.startRecorder(null);

              model.recording.value = !model.recording.value;
              print('startRecorder: ${model.recordUri}');
              model.recorderSubscription =
                  appModel.recorder.onRecorderStateChanged.listen((e) {
                model.duration = e.currentPosition.toInt();
                model.voiceLevel.value = Random().nextInt(7);
              });
            },
            onLongPressEnd: (details) async {
              String result = await appModel.recorder.stopRecorder();
              print('stopRecorder: $result');
              if (model.recorderSubscription != null) {
                model.recorderSubscription.cancel();
                model.recorderSubscription = null;
              }
              if (model.recordUri == null || model.recordUri.length <= 0) {
                return;
              }
              model.msgList.add(
                  Message(2, url: model.recordUri, duration: model.duration));
              model.recordUri = null;
              model.duration = 0;
              model.recording.value = !model.recording.value;
            },
            child: Row(
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    child: Text(
                      "按住 说话",
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () {},
                  ),
                )
              ],
            )),
        status: model.inputMode);
  }
}

class ControlPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = ViewModelProvider.of<ChatModel>(context);

    return Container(
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Row(
        children: <Widget>[
          ExchangeEx(
              child1: IconButton(
                padding: EdgeInsets.all(0),
                icon: Icon(Icons.keyboard_voice),
                onPressed: () {
                  model.inputMode.value = !model.inputMode.value;
                  model.panelVisible.value = false;
                },
              ),
              child2: IconButton(
                padding: EdgeInsets.all(0),
                icon: Icon(Icons.keyboard),
                onPressed: () {
                  model.inputMode.value = !model.inputMode.value;
                },
              ),
              status: model.inputMode),
          Expanded(child: InputModeTransformation()),
          IconButton(
            padding: EdgeInsets.all(0),
            icon: Icon(Icons.insert_emoticon),
            onPressed: () {},
          ),
          IconButton(
              padding: EdgeInsets.all(0),
              icon: Icon(Icons.add),
              onPressed: () {
                model.panelVisible.value = !model.panelVisible.value;
                print(model.panelVisible.value);
                model.inputMode.value = true;
              }),
          ListenableBridge(
              data: [model.inputMode, model.inputText],
              childBuilder: (context) {
                return Visibility(
                  child: RaisedButton(
                    child: Text(
                      "发 送",
                      style: TextStyle(color: Color(0xffffffff)),
                    ),
                    color: Color(0xFF0D47A1),
                    onPressed: () {
                      FocusScope.of(context).requestFocus();
                      model.msgList.add(Marker(0, DateTime.now().toString()));
                      model.msgList
                          .add(Message(0, text: model.inputText.value));
                      model.inputText.value = "";
                      print(model.dialogueScrollControl.position.runtimeType);
                      model.dialogueScrollControl
                          .jumpTo((model.msgList.length * 60).toDouble());
                    },
                  ),
                  visible:
                      model.inputMode.value && model.inputText.value.length > 0,
                );
              })
        ],
      ),
    );
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

class ImageMessage extends StatelessWidget {
  const ImageMessage(this.message);

  final Message message;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Image.network(
          "http://b-ssl.duitang.com/uploads/item/201811/04/20181104074412_wcelx.jpg",
          width: 28,
          height: 28,
        ),
        Container(
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
        )
      ],
    );
  }
}

class SoundMessage extends StatelessWidget {
  SoundMessage(this.message);

  final Message message;

  @override
  Widget build(BuildContext context) {
    final radio = min(max(message.duration.toInt() / (60 * 1000), 0.3), 1);
    final appModel = ViewModelProvider.of<AppModel>(context);
    return Row(
      children: <Widget>[
        Image.network(
          "http://b-ssl.duitang.com/uploads/item/201811/04/20181104074412_wcelx.jpg",
          width: 28,
          height: 28,
        ),
        Expanded(
            child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: radio,
          child: Container(
              margin: EdgeInsets.only(left: 16),
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
        ))
      ],
    );
  }
}

class TextMessage extends StatelessWidget {
  const TextMessage(this.message);

  final Message message;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Image.network(
          "http://b-ssl.duitang.com/uploads/item/201811/04/20181104074412_wcelx.jpg",
          width: 28,
          height: 28,
        ),
        Container(
          constraints: BoxConstraints(minWidth: 40, maxWidth: 200),
          margin: EdgeInsets.only(left: 16),
          padding: EdgeInsets.all(10),
          color: Color(0xffffffff),
          child: Text(
            message.text,
            softWrap: true,
            style: TextStyle(fontSize: 16),
          ),
        )
      ],
    );
  }
}

class ToolkitPanel extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ToolkitPanelState();
  }
}

class ToolkitPanelState extends State {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Color(0xfff1f1f1),
        height: 200,
        child: PageView(
            children: <Widget>[ToolkitPage(), ToolkitPage(), ToolkitPage()]));
  }
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
          .add(Message(1, file: image));
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
