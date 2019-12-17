import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/entities.dart';
import 'package:observable_ui/provider.dart';

import 'app_model.dart';
import 'audio_player.dart';
import 'widgets.dart';

const _kControlPanelHeight = 200.0;
const _kLrcBlockHeight = 30.0;
const _kLrcPanelHeight = 400.0;

class MusicPlayerPage extends StatelessWidget {
  final AudioLink song;

  const MusicPlayerPage({Key key, this.song}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appModel = ViewModelProvider.of<AppModel>(context);

    return Scaffold(
      body: _MusicPlayerPage(
        song: song,
        screenHeight: MediaQuery.of(context).size.height,
        audioPlayer: appModel.audioPlayer,
      ),
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
    return MusicPlayerPageState();
  }
}

class MusicPlayerPageState extends State<_MusicPlayerPage>
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

  Widget _build(BuildContext context, AudioLink song) {
    var appModel = ViewModelProvider.of<AppModel>(context);
    return Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                children: <Widget>[
                  PositionedTransition(
                    child: GestureDetector(
                      child: LrcPanel(
                        lrcBlocks: FAKE_LRC,
                        audioLink: song,
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
                        song: song,
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
                  audioLink: song,
                  playStream: appModel.audioPlayer.playStream,
                ))
          ],
        ),
        color: Color(0xff3f51b5));
  }

  @override
  Widget build(BuildContext context) {
    return _build(context, widget.song);
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
                Color(0xff3f51b5),
                Color(0xaa3f51b5),
                Color(0x663f51b5),
                Color(0x003f51b5),
              ])),
        ),
        Positioned(
          child: Text(
            song.name,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
            Text(_lastPlayEvent != null
                ? _lastPlayEvent.currentPositionText
                : "--:--:--"),
            Slider(
              min: 0,
              max: _lastPlayEvent != null ? _lastPlayEvent.duration : 0,
              value:
                  _lastPlayEvent != null ? _lastPlayEvent.currentPosition : 0,
              onChanged: (v) {
                appModel.audioPlayer.seekTo(v.toInt());
              },
            ),
            Text(_lastPlayEvent != null
                ? _lastPlayEvent.durationText
                : "--:--:--")
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

//  @override
//  Widget build(BuildContext context) {
//    var scrollOffset = 500.0;
//    if (_highlightBlock != null) {
//      scrollOffset = widget.lrcBlocks.indexOf(_highlightBlock) * 30.0;
//    }
//
//    var blocks = widget.lrcBlocks.map((block) {
//      if (block == _highlightBlock) {
//        return TextSpan(
//            text: block.text + "\n",
//            style: TextStyle(color: Colors.orange, fontSize: 16));
//      }
//
//      return TextSpan(text: block.text + "\n", style: TextStyle(fontSize: 16));
//    });
//
//    return CustomScrollView(
//      anchor: 0.5,
//      controller: ScrollController(initialScrollOffset: scrollOffset),
//      slivers: <Widget>[
//        SliverToBoxAdapter(
//          child: RichText(
//            textAlign: TextAlign.center,
//            text: TextSpan(
//                style: TextStyle(
//                  color: Colors.black,
//                ),
//                children: blocks.toList()),
//          ),
//        )
//      ],
//    );
//  }
  ScrollController scrollController =
      ScrollController(initialScrollOffset: _kLrcPanelHeight / 2);

  @override
  Widget build(BuildContext context) {
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
              style: TextStyle(color: Colors.orange, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            height: _kLrcBlockHeight,
          );
        }

        return SizedBox(
          child: Text(
            block.text + "\n",
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          height: _kLrcBlockHeight,
        );
      },
      itemCount: widget.lrcBlocks.length + 2,
      controller: scrollController,
    );

//    return CustomScrollView(
//      anchor: 0.5,
//      controller: scrollController,
//      slivers: <Widget>[
//        SliverPadding(
//          sliver: SliverFixedExtentList(
//            itemExtent: 30,
//            delegate: SliverChildBuilderDelegate((context, index) {
//              var block = widget.lrcBlocks[index];
//              if (block == _highlightBlock) {
//                return Text(
//                  block.text + "\n",
//                  style: TextStyle(color: Colors.orange, fontSize: 16),
//                  textAlign: TextAlign.center,
//                );
//              }
//              return Text(
//                block.text + "\n",
//                style: TextStyle(fontSize: 16),
//                textAlign: TextAlign.center,
//              );
//            }, childCount: widget.lrcBlocks.length),
//          ),
//          padding: EdgeInsets.only(bottom: 100),
//        )
//      ],
//    );
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
