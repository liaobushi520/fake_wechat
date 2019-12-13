import 'dart:async';

import 'package:flutter_app/utils.dart';
import 'package:flutter_sound/flutter_sound.dart';

import 'entities.dart';

class Response {
  final bool success;

  final String message;

  Response(this.success, this.message);
}

class AudioPlayer {
  final FlutterSound flutterSound = FlutterSound();

  AudioLink currentSong;

  StreamController<PlayEvent> _playStreamController =
      StreamController.broadcast();

  Stream get playStream => _playStreamController.stream;

  ///Flutter Sound 不会告诉我们音乐是否暂停，所以需要自己维护
  bool _paused = false;

  PlayEvent _lastPlayEvent;

  Future<bool> _startPlay(AudioLink song) async {
    if (flutterSound.isPlaying) {
      await flutterSound.stopPlayer();
    }
    var startPlayResponse = await flutterSound.startPlayer(song.url);
    if (startPlayResponse == song.url) {
      currentSong = song;
      var event = PlayEvent(currentSong, 1, 0, 0);
      _lastPlayEvent = event;
      _playStreamController.add(event);
      flutterSound.onPlayerStateChanged.listen((v) {
        if (v == null || _paused) {
          return;
        }
        PlayEvent event = (v.currentPosition == v.duration)
            ? PlayEvent(currentSong, -1, v.currentPosition, v.duration)
            : PlayEvent(currentSong, 1, v.currentPosition, v.duration);

        _lastPlayEvent = event;
        _playStreamController.add(event);
      });
      Future.value(true);
    } else {
      return Future.value(false);
    }
  }

  Future<bool> _stopPlay() async {
    if (flutterSound.isPlaying) {
      var stopPlayResponse = await flutterSound.stopPlayer();
      if (stopPlayResponse != null) {
        var event = PlayEvent(null, -1, 0, 0);
        _playStreamController.add(event);
        currentSong = null;
        _lastPlayEvent = null;
        _paused = false;
        return Future.value(true);
      } else {
        Future.value(false);
      }
    }

    return Future.value(true);
  }

  //// time mills
  Future<void> seekTo(int time) async {
    if (flutterSound.isPlaying) {
      await flutterSound.seekToPlayer(time);
    }
  }

  Future<bool> _pauseOrResume() async {
    if (_lastPlayEvent.status == 1) {
      var response = await flutterSound.pausePlayer();
      if (response != null) {
        var event = PlayEvent(currentSong, 0, _lastPlayEvent.currentPosition,
            _lastPlayEvent.duration);
        _lastPlayEvent = event;
        _playStreamController.add(event);
        _paused = true;
        return Future.value(true);
      } else {
        return Future.value(false);
      }
    } else if (_lastPlayEvent.status == 0) {
      var response = await flutterSound.resumePlayer();
      if (response != null) {
        var event = PlayEvent(currentSong, 1, _lastPlayEvent.currentPosition,
            _lastPlayEvent.duration);
        _lastPlayEvent = event;
        _playStreamController.add(event);
        _paused = false;
        return Future.value(true);
      } else {
        return Future.value(false);
      }
    }
  }

  Future<bool> playOrPause([AudioLink audioLink]) async {
    print("play or pause");
    if (audioLink != null) {
      ///同一首歌我们认为是暂停，恢复操作
      if (audioLink == currentSong) {
        return _pauseOrResume();
      }
      await _stopPlay();
      return _startPlay(audioLink);
    }

    return _pauseOrResume();
  }

  Future<bool> playOrStop([AudioLink audioLink, bool replay = false]) async {
    if (audioLink == null) {
      return _stopPlay();
    }
    if (!flutterSound.isPlaying) {
      return _startPlay(audioLink);
    } else {
      if (audioLink == currentSong && !replay) {
        return _stopPlay();
      }
      await _stopPlay();
      return _startPlay(audioLink);
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
