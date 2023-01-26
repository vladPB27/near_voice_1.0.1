import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:near_voice/model/colors.dart';
import 'package:near_voice/model/providers/actions_widget.dart';
import 'package:near_voice/model/providers/meeting.dart';
import 'package:near_voice/model/providers/user.dart';
import 'package:near_voice/model/soundStream_method.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'create_meeting.dart';
import 'package:near_voice/sound_stream.dart';
import 'package:web_socket_channel/io.dart';
import 'package:near_voice/model/env.dart';

class MeetCreated extends StatefulWidget {
  @override
  _MeetCreatedState createState() => _MeetCreatedState();
}

class _MeetCreatedState extends State<MeetCreated> {
  final soundMethods = SoundStreamMethod();

  RecorderStream _recorder = RecorderStream();
  PlayerStream _player = PlayerStream();

  bool _isRecording = false;
  bool _isPlaying = false;

  StreamSubscription _recorderStatus;
  StreamSubscription _playerStatus;
  StreamSubscription _audioStream;

  final channelAudio =
      IOWebSocketChannel.connect("ws://$ipPhoneServer:$PORT_AUDIO");

  final channelStr =
      IOWebSocketChannel.connect("ws://$ipPhoneServer:$PORT_STR");

  List<String> _listConnected = [];
  List<String> _listConnectedTemp = [];

  Timer _timer;

  @override
  void initState() {
    super.initState();
    final userInfo = Provider.of<User>(context, listen: false);
    initPlugin();

    Timer(Duration(milliseconds: 500), () async {
      await _player.start();
    });

    // _timer = Timer.periodic(Duration(seconds: 10), (Timer t) {
    //   channelStr.sink
    //       .add('?ru${userInfo.name}+//${userInfo.status}+//${userInfo.icon}');
    // });

    userInfo.micOn = 'micOf';
    _listConnected.add(
        '${userInfo.name}+//${userInfo.status}+//${userInfo.icon}+//${userInfo.micOn}');

    _listConnectedTemp
        .add('${userInfo.name}+//${userInfo.status}+//${userInfo.icon}');
  }

  @override
  void dispose() {
    _recorderStatus?.cancel();
    _playerStatus?.cancel();
    _audioStream?.cancel();
    channelAudio.sink.close();

    // channelStr.sink
    //     .add('--d$_userName+//$_userStatus.status+//$_userImage+//$_userIcon');
    Timer(Duration(milliseconds: 100), () {
      channelStr.sink.add('*ex*');
    });
    Timer(Duration(milliseconds: 300), () {
      channelStr.sink.close();
    });

    // _timer.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlugin() async {
    channelAudio.stream.listen((event) async {
      // print(event); // show frames
      if (_isPlaying) _player.writeChunk(event);
    });

    //stream from microphone
    _audioStream = _recorder.audioStream.listen((data) {
      channelAudio.sink.add(data);
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
    // await _player.stop();
    await _player.start();
    await _recorder.start();
    setState(() {
      _isRecording = true;
    });
  }

  void _stopRecord() async {
    await _recorder.stop();
    await _player.start();
    // await _player.stop();
    setState(() {
      _isRecording = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('MEET CREATED SCREEN');
    final actionsWidget = Provider.of<ActionsWidget>(context, listen: false);
    final userInfo = Provider.of<User>(context, listen: false);

    return WillPopScope(
      onWillPop: exitDialog,
      child: Scaffold(
        backgroundColor: ColorsNearVoice.primaryColor,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text(
            'Created',
            style: TextStyle(fontFamily: 'OverpassBold', fontSize: 24),
          ),
          backgroundColor: ColorsNearVoice.primaryColor,
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white),
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(0.0),
                        // child: UserConnectedServer(),
                        child: _userConnectedServer(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            ///iconButtons
            Container(
              color: ColorsNearVoice.primaryColor,
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.close_outlined,
                            size: 35,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            exitDialog();
                          },
                        ),
                        Text(
                          'End',
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.volume_off_outlined,
                            size: 35,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            _showMuteAllDialog(context);
                          },
                        ),
                        Text(
                          'Mic off all',
                          // actionsWidget.isMuted ? 'Mic off all' : 'Mic on all',
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            actionsWidget.isMuted
                                ? Icons.mic_off
                                : Icons.mic_outlined,
                            size: 35,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            channelStr.sink.add(
                                '@at${userInfo.name}+//${userInfo.status}+//${userInfo.icon}+//${userInfo.micOn}');
                            if (userInfo.micOn == 'micOf') {
                              userInfo.micOn = 'micOn';
                            } else {
                              userInfo.micOn = 'micOf';
                            }

                            actionsWidget.isMuted = !actionsWidget.isMuted;
                            if (actionsWidget.isMuted) {
                              _stopRecord();
                            } else {
                              _startRecord();
                            }
                          },
                        ),
                        Text(
                          actionsWidget.isMuted ? 'Mic Off' : 'Mic On',
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _userConnectedServer() {
    final actionsWidget = Provider.of<ActionsWidget>(context, listen: false);
    final meeting = Provider.of<Meeting>(context, listen: false);
    return Scaffold(
      backgroundColor: ColorsNearVoice.primaryColor,
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: StreamBuilder(
                stream: channelStr.stream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    Navigator.of(context).pop();
                  }
                  if (snapshot.hasError) {
                    Navigator.of(context).pop();
                  }
                  if (snapshot.hasData) {
                    var data = snapshot.data;
                    print('snapshot Server: $data');

                    _sendMeetingName(data, meeting);

                    if ((_listConnected.contains(data.substring(3)) == false) &&
                        (data.substring(0, 3) == '@ad')) {
                      _listConnected.add(data.substring(3));
                      sendUsers();
                    } else if (data.substring(0, 3) == '--d') {
                      _listConnected.remove(data.substring(3));
                      List<String> splitImg = data.split('+//');

                      Fluttertoast.showToast(
                          msg: '${splitImg[0].substring(3)} left the meeting',
                          toastLength: Toast.LENGTH_SHORT,
                          textColor: Colors.black);
                    }
                    imageMuted(data);

                    if ((_listConnectedTemp
                                .contains((snapshot.data).substring(3)) ==
                            false) &&
                        (snapshot.data).substring(0, 3) == '.ok') {
                      _listConnectedTemp.add((snapshot.data).substring(3));
                    }

                    print('list of connected: $_listConnected');

                    // if (snapshot.data == '?ru') {
                    //   Timer(Duration(seconds: 10), () {
                    //     print('getting in after 6 seconds');
                    //     _listConnected.removeWhere(
                    //             (element) => !_listConnectedTemp.contains(element));
                    //   });
                    // }

                    // _listConnectedTemp.clear();
                    // _listConnectedTemp.add(
                    //     '${userInfo.name}, ${userInfo.status}+img${userInfo.image}+img${userInfo.icon}');
                  }
                  return Column(
                    children: [
                      Expanded(
                          child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.white),
                        child: Column(
                          children: [
                            Expanded(child: listConnected(actionsWidget))
                          ],
                        ),
                      ))
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Future imageMuted(data) async {
    if ((data).substring(0, 3) == '@at') {
      // if(_listConnected.contains(data.substring(3))){
      if (data.substring(data.length - 5) == 'micOf') {
        int index = _listConnected.indexOf(data.substring(3));
        if (index >= 0) {
          String result = _listConnected[index].replaceAll('micOf', 'micOn');
          _listConnected[index] = result;
        }
      } else if (data.substring(data.length - 5) == 'micOn') {
        int index = _listConnected.indexOf(data.substring(3));
        if (index >= 0) {
          String result = _listConnected[index].replaceAll('micOn', 'micOf');
          _listConnected[index] = result;
        }
      }
      print('list replace: $_listConnected');
    }
  }

  _sendMeetingName(data, meeting) {
    if (data == '>hi') {
      channelStr.sink.add(
          '+nm${meeting.name}//${meeting.description}//$ipPhoneServer//${meeting.image}');
    }
  }

  listConnected(actionsWidget) {
    final meeting = Provider.of<Meeting>(context, listen: false);
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          collapsedHeight: 150,
          expandedHeight: MediaQuery.of(context).size.width * 0.7,
          // floating: true,
          automaticallyImplyLeading: false,
          elevation: 0,
          pinned: true,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30))),
          flexibleSpace: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                // height: 390,
                // width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30),
                  ),
                  image: DecorationImage(
                      image: AssetImage('assets/created-background.png'),
                      fit: BoxFit.cover),
                ),
                child: FlexibleSpaceBar(
                  titlePadding: EdgeInsets.only(left: 100, bottom: 20),
                  // collapseMode: CollapseMode.none,
                  centerTitle: true,
                  title: meeting.name != null
                      ? RichText(
                          text: TextSpan(children: [
                          TextSpan(
                            text: '${meeting.name}\n',
                            style: TextStyle(
                                color: HexColor('#002B33'),
                                fontSize: 18,
                                fontFamily: 'OverpassBold'),
                          ),
                          TextSpan(
                              text: '${meeting.description}',
                              style: TextStyle(
                                color: HexColor('#002B33'),
                                fontSize: 16,
                                // fontWeight: FontWeight.bold
                              ))
                        ]))
                      : Text(
                          'Meeting name',
                          style: TextStyle(
                            color: HexColor('#002B33'),
                            fontSize: 20,
                            // fontWeight: FontWeight.bold
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            [
              new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ListView.builder(
                      itemCount: _listConnected.length,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, index) {
                        List<String> _splitUser =
                            _listConnected[index].split('+//');
                        if (_splitUser[2] == 'null') {
                          _splitUser[2] = 'assets/user.png';
                        }
                        return GestureDetector(
                          onTap: () {
                            _showMuteDialog(context, actionsWidget,
                                _listConnected[index], _splitUser,index);
                          },
                          child: ListTile(
                            title: Padding(
                              padding: const EdgeInsets.only(
                                  top: 20, left: 30, right: 30),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 15),
                                    child: Container(
                                      height: 70,
                                      width: 70,
                                      decoration: BoxDecoration(
                                        color: ColorsNearVoice.primaryColor
                                            .withOpacity(0.8),
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            fit: BoxFit.fill,
                                            image: _splitUser[3] == 'micOn'
                                                ? AssetImage(_splitUser[2])
                                                : AssetImage(
                                                    'assets/user-3.png')),
                                                    // 'assets/muted-user-icon.png')),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(width: 0.5),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 25),
                                        // padding: EdgeInsets.all(10.0),
                                        child: Text(
                                          // '${_mapConnected[index][0]}',
                                          _splitUser[0],
                                          style: TextStyle(fontSize: 15),
                                        ),
                                      ),
                                      // height: 390,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // subtitle: Text('${_mapConnected[key]}',),
                          ),
                        );
                      }),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future sendUsers() async {
    for (String m in _listConnected) {
      await new Future.delayed(new Duration(milliseconds: 300));
      channelStr.sink.add('+us$m');
    }
  }

  _showMuteDialog(context, actionsWidget, list, split,index) {
    final heightDialog = MediaQuery.of(context).size.height * 0.23; //0.22
    final widthDialog = MediaQuery.of(context).size.width * 0.75; //0.65

    return showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Container(
            width: widthDialog,
            height: heightDialog,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              // color: ColorsNearVoice.primaryColor.withOpacity(0.8),
              color: ColorsNearVoice.primaryColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8, left: 20),
                            child: Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  fit: BoxFit.fill,
                                  image: split[2] != 'null'
                                      ? AssetImage(split[2])
                                      : AssetImage('assets/user.png'),
                                ),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                split[0],
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                              Text(
                                split[1],
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 18),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              channelStr.sink
                                  .add('1mu${split[0]}+//${split[1]}');
                                  // .add('1mu${split[0]}+//${split[1]}+//${split[2]}+//micOn');
                              Navigator.of(context).pop();
                              String result = _listConnected[index].replaceAll(
                                  'micOn', 'micOf');
                              _listConnected[index] = result;
                              print('result $result');
                              setState(() {

                              });
                              Timer(
                                Duration(milliseconds: 200), () {
                                  channelStr.sink.add('message to ignore');
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(15),
                                ),
                              ),
                              elevation: 7,
                              primary: ColorsNearVoice.thirdColor,
                              minimumSize:
                                  Size(widthDialog / 2, heightDialog / 3),
                            ),
                            child: Text('Mic off'),
                          ),
                        ),
                        Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                channelStr.sink
                                    .add('-rm${split[0]}+//${split[1]}');
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(15),
                                    ),
                                  ),
                                  elevation: 7,
                                  minimumSize:
                                      Size(widthDialog / 2, heightDialog / 3),
                                  primary: ColorsNearVoice.primaryColor,
                                  onPrimary: Colors.white),
                              child: Text('Remove')),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> exitDialog() {
    final heightDialog = MediaQuery.of(context).size.height * 0.23;
    final widthDialog = MediaQuery.of(context).size.width * 0.75;
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Container(
            width: widthDialog,
            height: heightDialog,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: ColorsNearVoice.primaryColor),
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        'Do you want to end the meeting?',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'OverpassRegular',
                            decoration: TextDecoration.none),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    // color: Colors.amberAccent,
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(15),
                                ),
                              ),
                              elevation: 7,
                              primary: ColorsNearVoice.thirdColor,
                              minimumSize:
                                  Size(widthDialog / 2, heightDialog / 3),
                              // onPrimary: Colors.amberAccent
                            ),
                            child: Text('Yes',
                                style: TextStyle(
                                    fontFamily: 'OverpassBold', fontSize: 18)),
                          ),
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(15),
                                  ),
                                ),
                                elevation: 7,
                                minimumSize:
                                    Size(widthDialog / 2, heightDialog / 3),
                                // primary: ColorsNearVoice.primaryColor,
                                primary: ColorsNearVoice.primaryColor,
                                onPrimary: Colors.white),
                            child: Text('No',
                                style: TextStyle(
                                    fontFamily: 'OverpassBold', fontSize: 18)),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _showMuteAllDialog(context) {
    final heightDialog = MediaQuery.of(context).size.height * 0.23;
    final widthDialog = MediaQuery.of(context).size.width * 0.75;

    return showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Container(
            width: widthDialog,
            height: heightDialog,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              // color: ColorsNearVoice.primaryColor.withOpacity(0.8),
              color: ColorsNearVoice.primaryColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        'Do you want to turn off all mics?',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontFamily: 'OverpassRegular',
                            decoration: TextDecoration.none),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              channelStr.sink.add('*all');
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(15),
                                ),
                              ),
                              elevation: 7,
                              primary: ColorsNearVoice.thirdColor,
                              minimumSize:
                                  Size(widthDialog / 2, heightDialog / 3),
                            ),
                            child: Text('Yes',
                                style: TextStyle(
                                    fontFamily: 'OverpassBold', fontSize: 18)),
                          ),
                        ),
                        Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(15),
                                    ),
                                  ),
                                  elevation: 7,
                                  minimumSize:
                                      Size(widthDialog / 2, heightDialog / 3),
                                  primary: ColorsNearVoice.primaryColor,
                                  onPrimary: Colors.white),
                              child: Text('No',
                                  style: TextStyle(
                                      fontFamily: 'OverpassBold',
                                      fontSize: 18))),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _send(String message) {
    if (channelStr != null) {
      if (channelStr.sink != null) {
        channelStr.sink.add(message);
      }
    }
  }
}
