import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:near_voice/sound_stream.dart';
import 'package:web_socket_channel/io.dart';

const _SERVER_URL = 'ws://4167c9d9.ngrok.io';

class TestingSoundStream extends StatefulWidget {
  const TestingSoundStream({Key key}) : super(key: key);

  @override
  _TestingSoundStreamState createState() => _TestingSoundStreamState();
}

class _TestingSoundStreamState extends State<TestingSoundStream> {
  RecorderStream _recorder = RecorderStream();
  PlayerStream _player = PlayerStream();

  bool _isRecording = false;
  bool _isPlaying = false;

  StreamSubscription _recorderStatus;
  StreamSubscription _playerStatus;
  StreamSubscription _audioStream;

  final channel = IOWebSocketChannel.connect(_SERVER_URL);

  @override
  void initState() {
    super.initState();
    initPlugin();
  }

  @override
  void dispose() {
    _recorderStatus?.cancel();
    _playerStatus?.cancel();
    _audioStream?.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlugin() async {
    channel.stream.listen((event) async {
      // print(event);
      if (_isPlaying) _player.writeChunk(event);
    });

    _audioStream = _recorder.audioStream.listen((data) {
      channel.sink.add(data);
    });

    _recorderStatus = _recorder.status.listen((status) {
      if (mounted)
        setState(() {
          _isRecording = status == SoundStreamStatus.Playing;
        });
    });

    _playerStatus = _player.status.listen((status) {
      if (mounted)
        setState(() {
          _isPlaying = status == SoundStreamStatus.Playing;
        });
    });

    await Future.wait([
      _recorder.initialize(),
      _player.initialize(),
    ]);
  }

  void _startRecord() async {
    await _player.stop();
    await _recorder.start();
    setState(() {
      _isRecording = true;
    });
  }

  void _stopRecord() async {
    await _recorder.stop();
    await _player.start();
    setState(() {
      _isRecording = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTapDown: (tap) {
                _startRecord();
              },
              onTapUp: (tap) {
                _stopRecord();
              },
              onTapCancel: () {
                _stopRecord();
              },
              child: Icon(
                _isRecording ? Icons.mic_off : Icons.mic,
                size: 128,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
int PORT = 8800;

void _runServerAudio() async {
  final connections = Set<WebSocket>();
  HttpServer.bind('192.168', PORT).then(
          (HttpServer server) {
        //own ip address
        server.listen((HttpRequest request) {
          WebSocketTransformer.upgrade(request).then((WebSocket ws) {
            connections.add(ws);
            print('[+]Connected AUDIO');
            ws.listen(
                  (data) {
                // Broadcast data to all other clients
                for (var conn in connections) {
                  if (conn != ws && conn.readyState == WebSocket.open) {
                    conn.add(data);
                    // print('serverData AUDIO: $data');
                  }
                }
              },
              onDone: () {
                connections.remove(ws);
                print('[-]Disconnected AUDIO');
              },
              onError: (err) {
                connections.remove(ws);
                print('[!]Error -- ${err.toString()}');
              },
              cancelOnError: true,
            );
          }, onError: (err) => print('[!]Error -- ${err.toString()}'));
        }, onError: (err) => print('[!]Error -- ${err.toString()}'));
      }, onError: (err) => print('[!]Error -- ${err.toString()}'));
}
