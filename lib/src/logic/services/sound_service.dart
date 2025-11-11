import 'package:audioplayers/audioplayers.dart';

/// Handles playback of the relaxing background soundtrack.
class SoundService {
  SoundService({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  bool _initialized = false;

  Future<void> start() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setSourceUrl(
      // Royalty-free ambient loop hosted externally to avoid bundling binaries.
      'https://files.freemusicarchive.org/storage-freemusicarchive-org/music/no_curator/'
      'Komiku/Its_time_for_adventure/Komiku_-_12_-_First_Steps.mp3',
    );
    await _player.resume();
  }

  Future<void> dispose() async {
    await _player.stop();
    await _player.dispose();
  }
}
