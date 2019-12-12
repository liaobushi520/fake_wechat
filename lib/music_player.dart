import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/entities.dart';
import 'package:observable_ui/provider.dart';

import 'app_model.dart';

class MusicPlayerModel {}

class MusicPlayerPage extends StatefulWidget {
  final AudioLink song;

  const MusicPlayerPage({Key key, this.song}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MusicPlayerPageState();
  }
}

class MusicPlayerPageState extends State<MusicPlayerPage> {
  @override
  Widget build(BuildContext context) {
    var appModel = ViewModelProvider.of<AppModel>(context);

    if (appModel.currentSong != widget.song) {
      appModel.playOrPause(widget.song);
    }

    return Scaffold(
      body: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 5.0,
          sigmaY: 5.0,
        ),
        child: Container(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      child: LrcPanel(
                        lrcBlocks: FAKE_LRC,
                        audioLink: appModel.currentSong,
                        playStream: appModel.playStream,
                      ),
                      height: 200,
                      bottom: 0,
                      left: 0,
                      right: 0,
                    ),
                    CoverPanel(
                      song: appModel.currentSong,
                    ),
                  ],
                ),
              ),
              PlayControlPanel(
                audioLink: appModel.currentSong,
                playStream: appModel.playStream,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CoverPanel extends StatelessWidget {
  final AudioLink song;

  const CoverPanel({Key key, this.song}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Image.network(song.cover),
        Positioned(
          child: Text(
            song.name,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          bottom: 0,
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
  PlayEvent _lastPlayEvent;

  StreamSubscription _subscription;

  @override
  Widget build(BuildContext context) {
    var appModel = ViewModelProvider.of<AppModel>(context);

    String duration = "--:--:--";

    String currentPosition = "--:--:--";

    double currentPositionD = 0;

    double durationD = 100;

    if (_lastPlayEvent != null) {
      durationD = _lastPlayEvent.duration / 1000;
      currentPositionD = _lastPlayEvent.currentPosition / 1000;
      duration = _lastPlayEvent.durationText;
      currentPosition = _lastPlayEvent.currentPositionText;
    }

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(currentPosition),
              Slider(
                min: 0,
                max: durationD,
                value: currentPositionD,
                onChanged: (v) {
                  appModel.seekTo(v.toInt());
                },
              ),
              Text(duration)
            ],
          ),
          IconButton(
            icon: _isPlay()
                ? Icon(
                    Icons.pause,
                    size: 40,
                  )
                : Icon(
                    Icons.play_arrow,
                    size: 40,
                  ),
            onPressed: () {
              appModel.playOrPause();
            },
          )
        ],
      ),
      padding: EdgeInsets.only(bottom: 30, top: 60),
    );
  }

  @override
  bool shouldRebuild(PlayEvent event, PlayEvent lastEvent) {
    return lastEvent == null ||
        (event.audio != widget.audioLink &&
            lastEvent.audio == widget.audioLink) ||
        (widget.audioLink == event.audio &&
            (lastEvent.status != event.status ||
                lastEvent.currentPosition != event.currentPosition));
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

///存在一个问题 ，高亮行要显示在中间
class LrcPanelState extends ReactPlayWidgetState<LrcPanel> {
  LrcBlock _highlightBlock;

  @override
  Widget _build(BuildContext context) {
    var blocks = widget.lrcBlocks.map((block) {
      if (block == _highlightBlock) {
        return TextSpan(
            text: block.text + "\n", style: TextStyle(color: Colors.orange));
      }

      return TextSpan(text: block.text + "\n");
    });

    return CustomScrollView(
      anchor: 0.5,
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                style: TextStyle(
                  color: Colors.black,
                ),
                children: blocks.toList()),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      anchor: 0.5,
      slivers: <Widget>[
        SliverFixedExtentList(
          itemExtent: 50,
          delegate: SliverChildBuilderDelegate((context, index) {
            var block = widget.lrcBlocks[index];
            if (block == _highlightBlock) {
              return Text(block.text + "\n",
                  style: TextStyle(color: Colors.orange));
            }
            return Text(block.text + "\n");
          }, childCount: widget.lrcBlocks.length),
        )
      ],
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
