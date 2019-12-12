import 'dart:async';

import 'package:flutter_app/entities.dart';
import 'package:flutter_app/utils.dart';
import 'package:flutter_sound/flutter_sound.dart';

const INVALID_TIME = -1.0;

class AppModel {
  final FlutterSound flutterSound = new FlutterSound();

  AudioLink currentSong;

  StreamController<PlayEvent> playStreamController =
      StreamController.broadcast();

  Stream get playStream => playStreamController.stream;

  ///Flutter Sound 不会告诉我们音乐是否暂停，所以需要自己维护
  bool _paused = false;

  PlayEvent _lastPlayEvent;

  void _startPlay(AudioLink song) async {
    if (flutterSound.isPlaying) {
      flutterSound.stopPlayer();
    }
    currentSong = song;
    flutterSound.startPlayer(song.url).then((v) {
      var event = PlayEvent(currentSong, 1, INVALID_TIME, INVALID_TIME);
      _lastPlayEvent = event;
      playStreamController.add(event);
      flutterSound.onPlayerStateChanged.listen((v) {
        if (v == null || _paused) {
          return;
        }
        var event = PlayEvent(currentSong, 1, v.currentPosition, v.duration);
        _lastPlayEvent = event;
        playStreamController.add(event);
      });
    });
  }

  void stopPlay() async {
    if (flutterSound.isPlaying) {
      flutterSound.stopPlayer().then((v) {
        var event = PlayEvent(null, -1, INVALID_TIME, INVALID_TIME);
        playStreamController.add(event);
        currentSong = null;
        _lastPlayEvent = null;
        _paused = false;
      });
    }
  }

  //// time mills
  void seekTo(int time) {
    if (flutterSound.isPlaying) {
      flutterSound.seekToPlayer(time);
    }
  }

  void _pauseOrResume() async {
    print("${_lastPlayEvent.status}");
    if (_lastPlayEvent.status == 1) {
      flutterSound.pausePlayer().then((e) {
        print("暂停播放");
        var event = PlayEvent(currentSong, 0, _lastPlayEvent.currentPosition,
            _lastPlayEvent.duration);
        _lastPlayEvent = event;
        playStreamController.add(event);
        _paused = true;
      }, onError: (e) {
        print(e);
      });
    } else if (_lastPlayEvent.status == 0) {
      flutterSound.resumePlayer().then((e) {
        print("恢复播放");
        var event = PlayEvent(currentSong, 1, _lastPlayEvent.currentPosition,
            _lastPlayEvent.duration);
        _lastPlayEvent = event;
        playStreamController.add(event);
        _paused = false;
      }, onError: (e) {
        print("e");
      });
    }
  }

  void playOrPause([AudioLink audioLink]) async {
    if (audioLink != null) {
      ///同一首歌我们认为是暂停，恢复操作
      if (audioLink == currentSong) {
        _pauseOrResume();
        return;
      }
      ////
      stopPlay();
      _startPlay(audioLink);
      return;
    }

    _pauseOrResume();
  }

  void playOrStop([AudioLink audioLink]) async {
    if (audioLink == null) {
      stopPlay();
      return;
    }

    if (!flutterSound.isPlaying) {
      _startPlay(audioLink);
    } else {
      if (audioLink == currentSong) {
        stopPlay();
        return;
      }
      stopPlay();
      _startPlay(audioLink);
    }
  }
}

class PlayEvent {
  final AudioLink audio;

  final int status; // 0 pause 1 play  -1 stop

  ///mills
  final double currentPosition;

  ///mills
  final double duration; //音乐总时长 -1未知

  String get currentPositionText => formatHHmmSS(currentPosition / 1000);

  String get durationText => formatHHmmSS(duration / 1000);

  const PlayEvent(this.audio, this.status, this.currentPosition, this.duration);
}
