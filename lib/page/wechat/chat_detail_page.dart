import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_app/data_source.dart';
import 'package:flutter_app/photo_preview.dart';
import 'package:flutter_app/server/ChatAI.dart';
import 'package:image_picker/image_picker.dart';
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

  GlobalKey _recorderPanelKey = GlobalKey();

  FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    var chatModel = ViewModelProvider.of<ChatModel>(context);

    return NotificationListener(
      child: Stack(
        children: <Widget>[
          Scaffold(
              appBar: AppBar(
                title: Text(chatModel.friend.name),
              ),
              body: Column(
                children: <Widget>[
                  Expanded(child: DialoguePanel()),
                  ControlPanel(
                    focusNode: _focusNode,
                  ),
                ],
              )),
          Center(
            child: RecorderPanel(key: _recorderPanelKey),
          )
        ],
      ),
      onNotification: (Notification notification) {
        if (notification is ControlNotification) {
          RecorderPanelState recorderPanelState =
              (_recorderPanelKey.currentContext as StatefulElement).state;
          recorderPanelState.handleControlEvent(notification);
        } else if (notification is UserScrollNotification) {
          if (_focusNode.hasFocus) {
            _focusNode.unfocus();
          }
        }
        return true;
      },
    );
  }
}

class RecorderPanel extends StatefulWidget {
  RecorderPanel({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return RecorderPanelState();
  }
}

class RecorderPanelState extends State<RecorderPanel>
    with TickerProviderStateMixin {
  ControlNotification _controlNotification;

  GlobalKey cancelBtnKey = GlobalKey();

  GlobalKey translateBtnKey = GlobalKey();

  bool _enterCancelBtnBounds = false;

  bool _enterTranslateBtnBounds = false;

  AnimationController _animationController, _animationController2;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 200),
        lowerBound: 1.0,
        upperBound: 1.3);
    _animationController2 = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 200),
        lowerBound: 1.0,
        upperBound: 1.3);
  }

  void handleControlEvent(ControlNotification notification) {
    bool invalidate = false;
    if (cancelBtnKey.currentContext != null &&
        translateBtnKey.currentContext != null) {
      RenderBox cancelBtnBox = cancelBtnKey.currentContext.findRenderObject();
      RenderBox translateBtnBox =
          translateBtnKey.currentContext.findRenderObject();

      var localOffset =
          cancelBtnBox.globalToLocal(notification.pointerEvent.position);
      if (cancelBtnBox.size.contains(localOffset) && !_enterCancelBtnBounds ||
          !cancelBtnBox.size.contains(localOffset) && _enterCancelBtnBounds) {
        _enterCancelBtnBounds = !_enterCancelBtnBounds;
        if (_enterCancelBtnBounds) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
        invalidate = true;
      }

      localOffset =
          translateBtnBox.globalToLocal(notification.pointerEvent.position);
      if (translateBtnBox.size.contains(localOffset) &&
              !_enterTranslateBtnBounds ||
          !translateBtnBox.size.contains(localOffset) &&
              _enterTranslateBtnBounds) {
        _enterTranslateBtnBounds = !_enterTranslateBtnBounds;
        if (_enterTranslateBtnBounds) {
          _animationController2.forward();
        } else {
          _animationController2.reverse();
        }

        invalidate = true;
      }
    }

    if (_controlNotification == null ||
        _controlNotification.event != notification.event) {
      invalidate = true;
    }

    if (invalidate) {
      setState(() {});
    }

    _controlNotification = notification;

    if (_controlNotification.event == -1) {
      _enterTranslateBtnBounds = false;
      _enterCancelBtnBounds = false;
      _animationController2.reset();
      _animationController.reset();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _animationController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controlNotification == null || _controlNotification.event == -1) {
      return Container();
    }
    final model = ViewModelProvider.of<ChatModel>(context);
    return Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        if (_controlNotification.event == 1)
          BackdropFilter(
            child: Container(color: Color.fromARGB(200, 0, 0, 0)),
            filter: ImageFilter.blur(
              sigmaX: 5.0,
              sigmaY: 5.0,
            ),
          ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 160,
              height: 160,
              child: Container(
                  decoration: _controlNotification.event == 0
                      ? BoxDecoration(
                          color: Color(0xaa000000),
                          borderRadius: BorderRadius.all(Radius.circular(10)))
                      : null,
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.keyboard_voice,
                        size: 70,
                        color: Colors.white,
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
            ),
            SizedBox(
              height: 40,
            ),
            Opacity(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: 40,
                  ),
                  ScaleTransition(
                    scale: _animationController,
                    child: Container(
                      key: cancelBtnKey,
                      width: 80,
                      height: 80,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                          Text("取消",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  decoration: TextDecoration.none))
                        ],
                      ),
                    ),
                  ),
                  Spacer(),
                  ScaleTransition(
                    scale: _animationController2,
                    child: Container(
                      key: translateBtnKey,
                      width: 80,
                      height: 80,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.blue),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.translate,
                            color: Colors.white,
                          ),
                          Text(
                            "转文字",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                decoration: TextDecoration.none),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 40,
                  ),
                ],
              ),
              opacity: _controlNotification.event == 1 ? 1 : 0,
            ),
          ],
        ),
      ],
    );
  }
}

class DialoguePanel extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var chatModel = ViewModelProvider.of<ChatModel>(context);

    ChatAI.listenMessage((message) {
      chatModel.msgList.add(Message(0, text: message, sender: FRIENDS[0]));
    });

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
              itemWidget = MessageBox(
                message: item,
              );
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
  final FocusNode focusNode;

  const ControlPanel({Key key, this.focusNode}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ControlPanelState();
  }
}

class ControlNotification extends Notification {
  final int event; // 0 录音手指在按钮范围内  1 录音手指不在按钮范围内   -1 结束录音

  final PointerEvent pointerEvent;

  const ControlNotification(this.event, this.pointerEvent);
}

class ControlPanelState extends State<ControlPanel> {
  bool _panelVisible = false;

  //false :录音  true :文本输入
  bool _inputMode = false;

  String _inputText = "";

  TextEditingController _textEditingController = TextEditingController();

  bool _recording = false;

  GlobalKey _recorderBtnKey = GlobalKey();

  void Function() _focusChangedListener;

  @override
  void initState() {
    super.initState();
    _focusChangedListener = () {
      if (_panelVisible && widget.focusNode.hasFocus) {
        setState(() {
          _panelVisible = false;
        });
      }
    };
    widget.focusNode.addListener(_focusChangedListener);
  }

  @override
  void dispose() {
    super.dispose();
    widget.focusNode.removeListener(_focusChangedListener);
  }

  _startRecording(ChatModel model, AppModel appModel) async {
    model.recordUri = await appModel.recorder.startRecorder();
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

  _sendTextMessage(ChatModel model, String text) async {
    String response = await ChatAI.sendMessage();


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

    return NotificationListener(
      child: WillPopScope(
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
                        width: 4,
                      ),
                      Expanded(
                        key: _recorderBtnKey,
                        child: DecoratedBox(
                          child: Padding(
                              child: _inputMode
                                  ? TextField(
                                      focusNode: widget.focusNode,
                                      decoration: null,
                                      maxLines: 5,
                                      minLines: 1,
                                      textAlign: TextAlign.start,
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
                                        ControlNotification(0, details)
                                            .dispatch(context);
                                      },
                                      onPointerMove: (details) async {
                                        var recorderBtn = (_recorderBtnKey
                                            .currentContext
                                            .findRenderObject() as RenderBox);
                                        var localOffset = recorderBtn
                                            .globalToLocal(details.position);
                                        var contain = recorderBtn.size
                                            .contains(localOffset);
                                        if (contain) {
                                          ControlNotification(0, details)
                                              .dispatch(context);
                                        } else {
                                          ControlNotification(1, details)
                                              .dispatch(context);
                                        }
                                      },
                                      onPointerUp: (details) async {
                                        _stopRecording(model, appModel);
                                        ControlNotification(-1, details)
                                            .dispatch(context);
                                      }),
                              padding: EdgeInsets.all(8)),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(2)),
                              color: _recording
                                  ? Color.fromARGB(255, 160, 160, 160)
                                  : Colors.white),
                        ),
                      ),
                      SizedBox(
                        width: 4,
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
                      SizedBox(
                        width: 4,
                      ),
                      AnimatedContainer(
                        curve: Curves.easeInToLinear,
                        duration: Duration(milliseconds: 300),
                        width: _inputMode && _inputText.length > 0 ? 50 : 30,
                        height: 30,
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
                                  maxLines: 1,
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
                                  //hide keyboard
                                  if (widget.focusNode.hasFocus) {
                                    widget.focusNode.unfocus();
                                  }
                                  setState(() {
                                    _inputMode = true;
                                    _panelVisible = !_panelVisible;
                                  });
                                },
                              ),
                      )
                    ],
                  ),
                  padding:
                      EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 5),
                ),
                Visibility(
                  child: SizedBox(
                      height: 260,
                      child: PageView(children: <Widget>[
                        ToolkitPage(
                          entrances: ToolkitEntrances,
                        )
                      ])),
                  visible: _panelVisible,
                )
              ],
            ),
          )),
      onNotification: (notification) {
        ///TextField contains Scrollable , we prevent scroll event  bubble up
        if (notification is ScrollNotification) {
          return true;
        }
        return false;
      },
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

class MessageBox extends StatefulWidget {
  final Message message;

  const MessageBox({Key key, this.message}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MessageBoxState();
  }
}

class MessageBoxState extends State<MessageBox> {
  @override
  Widget build(BuildContext context) {
    Widget child;
    switch (widget.message.type) {
      case 0:
        {
          child = _buildTextBox(context, widget.message);
          break;
        }
      case 1:
        {
          child = _buildImageBox(context, widget.message);
          break;
        }
      case 2:
        {
          child = _buildSoundBox(context, widget.message);
          break;
        }
      default:
        {
          child = Text("暂不支持该消息类型!");
        }
    }

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
          SizedBox(
            width: 10,
          ),
          child,
        ],
      ),
      textDirection:
          widget.message.sender == USER ? TextDirection.rtl : TextDirection.ltr,
    );
  }

  Widget _buildImageBox(BuildContext context, Message message) {
    return Container(
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

  Widget _buildSoundBox(BuildContext context, Message message) {
    final radio = min(max(message.duration.toInt() / (60 * 1000), 0.3), 1);
    final appModel = ViewModelProvider.of<AppModel>(context);
    return Expanded(
        child: FractionallySizedBox(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: radio,
      child: GestureDetector(
        child: Container(
          padding: EdgeInsets.all(8),
          child: Text(
            "${message.duration.toInt() ~/ 1000}'",
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 16),
          ),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(2),
            color: message.sender == USER
                ? Color.fromARGB(255, 169, 232, 122)
                : Color(0xffffffff),
          ),
        ),
        onTap: () {
          appModel.recorder.startPlayer(message.url).then((s) {});
        },
      ),
    ));
  }

  Widget _buildTextBox(BuildContext context, Message message) {
    return Container(
      constraints: BoxConstraints(maxWidth: 200),
      padding: EdgeInsets.all(7),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(2),
        color: message.sender == USER
            ? Color.fromARGB(255, 169, 232, 122)
            : Color(0xffffffff),
      ),
      child: Text(
        message.text,
        softWrap: true,
        style: TextStyle(fontSize: 16),
        textDirection: TextDirection.ltr,
      ),
    );
  }
}

class ToolkitPage extends StatefulWidget {
  final List<ToolkitEntrance> entrances;

  const ToolkitPage({Key key, this.entrances}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ToolkitPageState();
  }
}

class ToolkitEntrance {
  final String name;

  final IconData icon;

  const ToolkitEntrance(this.name, this.icon);
}

final ToolkitEntrances = <ToolkitEntrance>[
  ToolkitEntrance("相册", Icons.image),
  ToolkitEntrance("拍摄", Icons.camera),
  ToolkitEntrance("文件", Icons.attach_file),
  ToolkitEntrance("红包", Icons.account_balance_wallet)
];

class ToolkitPageState extends State<ToolkitPage> {
  Future sendImageMessage(BuildContext context, ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source);
    if (image != null) {
      ViewModelProvider.of<ChatModel>(context)
          .msgList
          .add(Message(1, file: image, sender: USER));
    }
  }

  Widget _buildToolkitEntrance(BuildContext context, ToolkitEntrance item) {
    BoxDecoration iconDecoration = BoxDecoration(
        borderRadius: BorderRadius.circular(4), color: Colors.white);
    return Expanded(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        DecoratedBox(
          child: IconButton(
              icon: Icon(item.icon),
              onPressed: () {
                if (item.name == "相册") {
                  sendImageMessage(context, ImageSource.gallery);
                } else if (item.name == "拍摄") {
                  sendImageMessage(context, ImageSource.camera);
                } else if (item.name == "文件") {
                } else if (item.name == "红包") {}
              }),
          decoration: iconDecoration,
        ),
        Text(item.name)
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    var countForRow = 3;
    int rowCount = ((widget.entrances.length / countForRow) + 0.5).round();
    var rows = <Widget>[];
    for (int i = 0; i < rowCount; i++) {
      var widgets = <Widget>[];
      for (int j = countForRow * i;
          j < min(widget.entrances.length, countForRow * (i + 1));
          j++) {
        var item = widget.entrances[j];
        widgets.add(
          _buildToolkitEntrance(context, item),
        );
      }

      if (i == rowCount - 1) {
        for (int k = widget.entrances.length;
            k < (rowCount) * countForRow;
            k++) {
          widgets.add(Spacer());
        }
      }
      rows.add(Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widgets,
        ),
      ));
    }

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: rows,
      ),
      color: Color(0xfff1f1f1),
      padding: EdgeInsets.all(16),
      alignment: Alignment.center,
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
