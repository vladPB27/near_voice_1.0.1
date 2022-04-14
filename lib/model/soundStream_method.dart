import '../sound_stream.dart';

class SoundStreamMethod {
  RecorderStream _recorder = RecorderStream();
  PlayerStream _player = PlayerStream();
  bool _isRecording = false;
  bool _isPlaying = false;


  void startRecord() async {
    // await _player.stop();
    await _player.start();
    await _recorder.start();
    _isRecording = true;
  }

  void stopRecord() async {
    await _recorder.stop();
    await _player.start();
    // await _player.stop();
    _isRecording = false;
  }
}
