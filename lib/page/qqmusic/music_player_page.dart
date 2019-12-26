import 'dart:async';
import 'dart:collection';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/entities.dart';
import 'package:http/http.dart' as http;
import 'package:observable_ui/provider.dart';
import 'package:palette_generator/palette_generator.dart';

import '../../app_model.dart';
import '../../widgets.dart';
import 'audio_player.dart';

const _kControlPanelHeight = 200.0;
const _kLrcBlockHeight = 30.0;
const _kLrcPanelHeight = 400.0;

class MusicPlayerThemeData {
  final Color primaryColor;

  final TextStyle titleTextStyle;

  final TextStyle highlightTextStyle;

  final TextStyle normalTextStyle;

  final TextStyle timeIndicatorTextStyle;

  final SliderThemeData sliderTheme;

  final IconThemeData iconTheme;

  const MusicPlayerThemeData({
    this.titleTextStyle,
    this.highlightTextStyle,
    this.normalTextStyle,
    this.timeIndicatorTextStyle,
    this.sliderTheme,
    this.iconTheme,
    this.primaryColor,
  });

  MusicPlayerThemeData copyWith({
    TextStyle titleTextStyle,
    TextStyle highlightTextStyle,
    TextStyle normalTextStyle,
    TextStyle timeIndicatorTextStyle,
    SliderThemeData sliderTheme,
    IconThemeData iconTheme,
    Color primaryColor,
  }) {
    return MusicPlayerThemeData(
        timeIndicatorTextStyle:
            timeIndicatorTextStyle ?? this.timeIndicatorTextStyle,
        titleTextStyle: titleTextStyle ?? this.titleTextStyle,
        highlightTextStyle: highlightTextStyle ?? this.highlightTextStyle,
        normalTextStyle: normalTextStyle ?? this.normalTextStyle,
        sliderTheme: sliderTheme ?? this.sliderTheme,
        iconTheme: iconTheme ?? this.iconTheme,
        primaryColor: primaryColor ?? this.primaryColor);
  }
}

class MusicPlayerTheme extends InheritedTheme {
  final MusicPlayerThemeData data;

  MusicPlayerTheme({
    this.data,
    Widget child,
    Key key,
  })  : assert(child != null),
        assert(data != null),
        super(key: key, child: child);
  static Color primaryColor = Color(0xff000000),
      titleTextColor = Color(0xffffffff),
      bodyTextColor = Color(0xffe3e3e3);

  static MusicPlayerThemeData DEFAULT_MUSIC_PLAYER_THEME;

  static MusicPlayerThemeData of(BuildContext context) {
    final MusicPlayerTheme inheritedTheme =
        context.dependOnInheritedWidgetOfExactType<MusicPlayerTheme>();
    if (inheritedTheme != null && inheritedTheme.data != null) {
      return inheritedTheme.data;
    } else {
      if (DEFAULT_MUSIC_PLAYER_THEME == null) {
        ThemeData themeData = Theme.of(context);
        SliderThemeData sliderTheme = themeData.sliderTheme;
        IconThemeData iconThemeData = themeData.iconTheme;
        DEFAULT_MUSIC_PLAYER_THEME = MusicPlayerThemeData(
            primaryColor: primaryColor,
            sliderTheme: sliderTheme.copyWith(
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.0),
                activeTrackColor: titleTextColor,
                thumbColor: titleTextColor,
                inactiveTrackColor: titleTextColor.withOpacity(0.1)),
            iconTheme: iconThemeData.copyWith(color: titleTextColor),
            titleTextStyle: TextStyle(
                color: titleTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 16),
            highlightTextStyle: TextStyle(
                color: titleTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 14),
            normalTextStyle:
                TextStyle(color: bodyTextColor.withOpacity(0.5), fontSize: 14),
            timeIndicatorTextStyle:
                TextStyle(color: bodyTextColor, fontSize: 12));
      }
    }

    return DEFAULT_MUSIC_PLAYER_THEME;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    final SliderTheme ancestorTheme =
        context.findAncestorWidgetOfExactType<SliderTheme>();
    return identical(this, ancestorTheme)
        ? child
        : MusicPlayerTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(MusicPlayerTheme oldWidget) => data != oldWidget.data;
}

Map<String, PaletteGenerator> paletteCache = HashMap();

class MusicPlayerPage extends StatefulWidget {
  final AudioLink song;

  const MusicPlayerPage({Key key, this.song}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MusicPlayerPageState();
  }
}

class MusicPlayerPageState extends State<MusicPlayerPage> {
  PaletteGenerator _paletteGenerator;

  @override
  void initState() {
    super.initState();

    if (paletteCache.containsKey(widget.song.cover)) {
      _paletteGenerator = paletteCache[widget.song.cover];
    } else {
      exactColors(widget.song.cover).then((v) {
        paletteCache[widget.song.cover] = v;
        setState(() {
          _paletteGenerator = v;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var appModel = ViewModelProvider.of<AppModel>(context);
    MusicPlayerThemeData themeData = MusicPlayerTheme.of(context);
    if (_paletteGenerator != null) {
      Color primaryColor = _paletteGenerator.lightMutedColor.color;
      Color titleTextColor = _paletteGenerator.lightMutedColor.titleTextColor;
      Color bodyTextColor = _paletteGenerator.lightMutedColor.bodyTextColor;
      themeData = themeData.copyWith(
          primaryColor: primaryColor,
          titleTextStyle:
              themeData.titleTextStyle.copyWith(color: titleTextColor),
          highlightTextStyle:
              themeData.highlightTextStyle.copyWith(color: titleTextColor),
          normalTextStyle:
              themeData.normalTextStyle.copyWith(color: bodyTextColor),
          sliderTheme: themeData.sliderTheme.copyWith(
              activeTrackColor: titleTextColor,
              thumbColor: titleTextColor,
              inactiveTrackColor: titleTextColor.withOpacity(0.1)),
          iconTheme: themeData.iconTheme.copyWith(color: titleTextColor),
          timeIndicatorTextStyle:
              themeData.timeIndicatorTextStyle.copyWith(color: bodyTextColor));
    }

    return Scaffold(
      body: Container(
          child: MusicPlayerTheme(
            data: themeData,
            child: _MusicPlayerPage(
              song: widget.song,
              screenHeight: MediaQuery.of(context).size.height,
              audioPlayer: appModel.audioPlayer,
            ),
          ),
          color: themeData.primaryColor),
    );
  }
}

class _MusicPlayerPage extends StatefulWidget {
  final AudioLink song;

  final double screenHeight;

  final AudioPlayer audioPlayer;

  const _MusicPlayerPage(
      {Key key, this.song, this.screenHeight, this.audioPlayer})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MusicPlayerPageState();
  }
}

class _MusicPlayerPageState extends State<_MusicPlayerPage>
    with SingleTickerProviderStateMixin {
  bool _expand = false;

  AnimationController _controller;

  Animation<RelativeRect> _animation;

  Animation<RelativeRect> _lrcAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    var rectTween = RelativeRectTween(
        begin: RelativeRect.fromLTRB(0, 0, 0, _kLrcBlockHeight),
        end: RelativeRect.fromLTRB(0, -_kLrcPanelHeight, 0, _kLrcPanelHeight));
    var lrcRectTween = RelativeRectTween(
        begin: RelativeRect.fromLTRB(
            0,
            this.widget.screenHeight -
                _kControlPanelHeight -
                _kLrcPanelHeight / 2 -
                2 * _kLrcBlockHeight,
            0,
            -_kLrcPanelHeight / 2 + 2 * _kLrcBlockHeight),
        end: RelativeRect.fromLTRB(
            0,
            widget.screenHeight - _kControlPanelHeight - _kLrcPanelHeight,
            0,
            0));
    _animation = rectTween.animate(_controller);
    _lrcAnimation = lrcRectTween.animate(_controller);

    if (widget.song != widget.audioPlayer.currentSong) {
      widget.audioPlayer.playOrPause(widget.song);
    }
  }

  _handleExpand() {
    if (_controller.isAnimating) {
      return;
    }
    if (!_expand) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _expand = !_expand;
  }

  @override
  Widget build(BuildContext context) {
    var appModel = ViewModelProvider.of<AppModel>(context);
    return Column(
      children: <Widget>[
        Expanded(
          child: Stack(
            children: <Widget>[
              PositionedTransition(
                child: GestureDetector(
                  child: LrcPanel(
                    lrcBlocks: FAKE_LRC,
                    audioLink: widget.song,
                    playStream: appModel.audioPlayer.playStream,
                  ),
                  onTap: () {
                    if (_expand) {
                      return;
                    }
                    _handleExpand();
                  },
                ),
                rect: _lrcAnimation,
              ),
              PositionedTransition(
                child: VerticalGestureDetector(
                  child: CoverPanel(
                    song: widget.song,
                  ),
                  onEvent: (e) {
                    if (e == VerticalEvent.UP && !_expand ||
                        e == VerticalEvent.DOWN && _expand) {
                      _handleExpand();
                    }
                  },
                ),
                rect: _animation,
              ),
            ],
          ),
        ),
        SizedBox(
            height: _kControlPanelHeight,
            child: PlayControlPanel(
              audioLink: widget.song,
              playStream: appModel.audioPlayer.playStream,
            ))
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

class CoverPanel extends StatelessWidget {
  final AudioLink song;

  const CoverPanel({Key key, this.song}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MusicPlayerThemeData themeData = MusicPlayerTheme.of(context);
    return Stack(
      children: <Widget>[
        SizedBox.expand(
          child: Image.network(
            song.cover,
            fit: BoxFit.cover,
          ),
        ),
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                themeData.primaryColor.withOpacity(1.0),
                themeData.primaryColor.withOpacity(0.6),
                themeData.primaryColor.withOpacity(0.4),
                themeData.primaryColor.withOpacity(0.0),
              ])),
        ),
        Positioned(
          child: Text(
            song.name,
            style: themeData.titleTextStyle,
            textAlign: TextAlign.center,
          ),
          bottom: 10,
          left: 0,
          right: 0,
        ),
      ],
    );
  }
}

abstract class ReactPlayWidget extends StatefulWidget {
  final AudioLink audioLink;

  final Stream playStream;

  const ReactPlayWidget({Key key, this.audioLink, this.playStream})
      : super(key: key);

  @override
  ReactPlayWidgetState createState();
}

abstract class ReactPlayWidgetState<T extends ReactPlayWidget>
    extends State<T> {
  PlayEvent _lastPlayEvent;

  StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.playStream.listen((e) {
      if (shouldRebuild(e, _lastPlayEvent)) {
        setState(() {});
      }
      _lastPlayEvent = e;
    });
  }

  bool _isPlay() {
    return _lastPlayEvent != null &&
        _lastPlayEvent.audio == widget.audioLink &&
        _lastPlayEvent.status == 1;
  }

  bool shouldRebuild(PlayEvent event, PlayEvent lastEvent);

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
  }
}

class PlayControlPanel extends ReactPlayWidget {
  final AudioLink audioLink;

  final Stream playStream;

  const PlayControlPanel({Key key, this.audioLink, this.playStream})
      : super(key: key);

  @override
  PlayControlPanelState createState() {
    return PlayControlPanelState();
  }
}

class PlayControlPanelState extends ReactPlayWidgetState<PlayControlPanel> {
  @override
  Widget build(BuildContext context) {
    var appModel = ViewModelProvider.of<AppModel>(context);
    MusicPlayerThemeData themeData = MusicPlayerTheme.of(context);
    if (_lastPlayEvent != null && _lastPlayEvent.status == -1) {
      appModel.audioPlayer.playOrStop(widget.audioLink, true);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _lastPlayEvent != null
                  ? _lastPlayEvent.currentPositionText
                  : "--:--:--",
              style: themeData.timeIndicatorTextStyle,
            ),
            SliderTheme(
              child: Slider(
                min: 0,
                max: _lastPlayEvent != null ? _lastPlayEvent.duration : 0,
                value:
                    _lastPlayEvent != null ? _lastPlayEvent.currentPosition : 0,
                onChanged: (v) {
                  appModel.audioPlayer.seekTo(v.toInt());
                },
              ),
              data: themeData.sliderTheme,
            ),
            Text(
              _lastPlayEvent != null ? _lastPlayEvent.durationText : "--:--:--",
              style: themeData.timeIndicatorTextStyle,
            )
          ],
        ),
        IconButton(
          icon: _isPlay()
              ? Icon(
                  Icons.pause,
                  size: 36,
                )
              : Icon(
                  Icons.play_arrow,
                  size: 36,
                ),
          onPressed: () {
            appModel.audioPlayer.playOrPause();
          },
        ),
        SizedBox(
          height: 30,
        )
      ],
    );
  }

  @override
  bool shouldRebuild(PlayEvent event, PlayEvent lastEvent) {
    var needBuild = lastEvent == null ||
        (event.audio != widget.audioLink &&
            lastEvent.audio == widget.audioLink) ||
        (widget.audioLink == event.audio &&
            (lastEvent.status != event.status ||
                lastEvent.currentPosition != event.currentPosition));

    return needBuild;
  }
}

class LrcPanel extends ReactPlayWidget {
  final List<LrcBlock> lrcBlocks;

  const LrcPanel(
      {Key key, this.lrcBlocks, AudioLink audioLink, Stream playStream})
      : super(key: key, audioLink: audioLink, playStream: playStream);

  @override
  ReactPlayWidgetState createState() {
    return LrcPanelState();
  }
}

class LrcPanelState extends ReactPlayWidgetState<LrcPanel> {
  LrcBlock _highlightBlock;

  ScrollController scrollController =
      ScrollController(initialScrollOffset: _kLrcPanelHeight / 2);

  @override
  Widget build(BuildContext context) {
    MusicPlayerThemeData themeData = MusicPlayerTheme.of(context);
    return ListView.builder(
      itemBuilder: (context, index) {
        if (index == 0) {
          return SizedBox(
            height: _kLrcPanelHeight / 2,
          );
        }

        if (index == widget.lrcBlocks.length + 1) {
          return SizedBox(
            height: _kLrcPanelHeight / 2,
          );
        }

        var block = widget.lrcBlocks[index - 1];
        if (block == _highlightBlock) {
          return SizedBox(
            child: Text(
              block.text + "\n",
              style: themeData.highlightTextStyle,
              textAlign: TextAlign.center,
            ),
            height: _kLrcBlockHeight,
          );
        }

        return SizedBox(
          child: Text(
            block.text + "\n",
            style: themeData.normalTextStyle,
            textAlign: TextAlign.center,
          ),
          height: _kLrcBlockHeight,
        );
      },
      itemCount: widget.lrcBlocks.length + 2,
      controller: scrollController,
    );
  }

  @override
  bool shouldRebuild(PlayEvent event, PlayEvent lastEvent) {
    LrcBlock block;
    for (int i = 0; i < widget.lrcBlocks.length; i++) {
      if (event.currentPosition >= widget.lrcBlocks[i].time &&
          (i == widget.lrcBlocks.length - 1 ||
              event.currentPosition < widget.lrcBlocks[i + 1].time)) {
        block = widget.lrcBlocks[i];
      }
    }
    var needRebuild = block != _highlightBlock;
    _highlightBlock = block;

    if (needRebuild) {
      var scrollOffset = 0.0;
      if (_highlightBlock != null) {
        scrollOffset =
            widget.lrcBlocks.indexOf(_highlightBlock) * _kLrcBlockHeight;
      }
      scrollController.animateTo(scrollOffset,
          duration: Duration(milliseconds: 100), curve: Curves.ease);
    }

    return needRebuild;
  }
}

const FAKE_LRC = [
  LrcBlock(time: 2100, text: "杨宗纬 - 回忆沙漠"),
  LrcBlock(time: 20690, text: "可能是寂寞让人闯祸"),
  LrcBlock(time: 27570, text: "我的心破了个洞"),
  LrcBlock(time: 32900, text: "时间的酒我喝很多"),
  LrcBlock(time: 39840, text: "醒来后思念来得那么凶"),
  LrcBlock(time: 47620, text: "想她的时候云在滚动"),
  LrcBlock(time: 54240, text: "让时缺不肯随风"),
  LrcBlock(time: 59710, text: "今天的我孤单生活"),
  LrcBlock(time: 66740, text: "每一步都踏在烈日中"),
  LrcBlock(time: 74270, text: "回忆沙漠不看着反会痛"),
  LrcBlock(time: 81330, text: "我喊了一声祝福他听见没有"),
  LrcBlock(time: 87610, text: "没有明天的人哪怕寂寞"),
  LrcBlock(time: 94550, text: "别管我要往哪里走"),
];

class LrcBlock {
  final num time;

  final String text;

  const LrcBlock({this.time, this.text});
}

Future<PaletteGenerator> exactColors(String imageURL) async {
  ///  very serious   *****
  // return await PaletteGenerator.fromImageProvider(NetworkImage(imageURL));

  /// serious **
  ReceivePort receivePort = ReceivePort();
  await Isolate.spawn(entryPoint, receivePort.sendPort);
  SendPort sendPort = await receivePort.first;
  Uint8List bytes = await sendReceive(sendPort, imageURL);
  var image =
      (await (await ui.instantiateImageCodec(bytes)).getNextFrame()).image;
  return await PaletteGenerator.fromImage(image);
}

entryPoint(SendPort sendPort) async {
  ReceivePort port = ReceivePort();
  sendPort.send(port.sendPort);
  await for (var msg in port) {
    SendPort replyTo = msg[1];
    if (msg[0] is String) {
      http.Response response = await http.get(msg[0]);
      replyTo.send(response.bodyBytes);
    }
  }
}

Future sendReceive(SendPort port, msg) {
  ReceivePort response = ReceivePort();
  port.send([msg, response.sendPort]);
  return response.first;
}
