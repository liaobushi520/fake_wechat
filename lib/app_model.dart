import 'package:flutter_app/page/qqmusic/audio_player.dart';
import 'package:flutter_sound/flutter_sound.dart';

class AppModel {
  final AudioPlayer audioPlayer = AudioPlayer();

  final FlutterSoundRecorder recorder =  FlutterSoundRecorder();

  final FlutterSoundPlayer player = FlutterSoundPlayer();

}
