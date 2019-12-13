import 'package:flutter_app/audio_player.dart';
import 'package:flutter_sound/flutter_sound.dart';

class AppModel {
  final AudioPlayer audioPlayer = AudioPlayer();

  final FlutterSound recorder = new FlutterSound();
}
