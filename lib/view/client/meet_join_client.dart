import 'dart:async';
import 'dart:convert';

// import 'dart:html';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:near_voice/model/colors.dart';
import 'package:near_voice/model/providers/actions_widget.dart';
import 'package:near_voice/model/providers/meeting.dart';
import 'package:near_voice/model/providers/user.dart';
import 'package:near_voice/sound_stream.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:io';
import 'package:web_socket_channel/status.dart' as status;

import 'connect_meeting.dart';
import 'package:near_voice/model/env.dart';

class MeetJoin extends StatefulWidget {
  MeetJoin({
    Key key,
  }) : super(key: key);

  @override
  _MeetJoinState createState() => _MeetJoinState();
}

class _MeetJoinState extends State<MeetJoin> {
  String _userName;
  String _userStatus;
  String _userImage;
  String _userIcon;
  String _userMic;
  List<String> _listConnected = [];

  RecorderStream _recorder = RecorderStream();
  PlayerStream _player = PlayerStream();

  bool _isRecording = false;
  bool _isPlaying = false;

  StreamSubscription _recorderStatus;
  StreamSubscription _playerStatus;
  StreamSubscription _audioStream;

  final channelAudio = IOWebSocketChannel.connect("ws://$ipEnter:$PORT_AUDIO");

  final channelStr = IOWebSocketChannel.connect("ws://$ipEnter:$PORT_STR");

  // final channelStr = IOWebSocketChannel.connect("ws://$ipEnter:$PORT_STR",
  //     pingInterval: Duration(milliseconds: 5000));

  @override
  void initState() {
    super.initState();
    initPlugin();

    Timer(Duration(milliseconds: 500), () async {
      // startRecord();
      await _player.start();
    });
  }

  @override
  void dispose() {
    _recorderStatus?.cancel();
    _playerStatus?.cancel();
    _audioStream?.cancel();
    channelAudio.sink.close();

    channelStr.sink.add('--d$_userName+//$_userStatus+//$_userIcon+//$_userMic');
    print('to clear: $_userName, $_userStatus');
    _listConnected.clear();
    channelStr.sink.close();

    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlugin() async {
    channelAudio.stream.listen((event) async {
      // print(event);
      if (_isPlaying) _player.writeChunk(event);
    });

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

  void startRecord() async {
    // await _player.stop();
    await _player.start();
    await _recorder.start();
    setState(() {
      _isRecording = true;
    });
  }

  void stopRecord() async {
    await _recorder.stop();
    await _player.start();
    // await _player.stop();
    setState(() {
      _isRecording = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('MEET JOIN SCREEN');
    final actionsWidget = Provider.of<ActionsWidget>(context, listen: false);
    final userInfo = Provider.of<User>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Connected',
          style: TextStyle(
              fontFamily: 'OverpassBold', color: Colors.white, fontSize: 24),
        ),
        backgroundColor: HexColor('#006059'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Container(
                        child: usersConnected(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          ///icon buttons
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
                        'Exit',
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
                          actionsWidget.isSilenced
                              ? Icons.volume_off_outlined
                              : Icons.volume_up_outlined,
                          size: 35,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          actionsWidget.isSilenced = !actionsWidget.isSilenced;
                          if (actionsWidget.isSilenced) {
                            _player.stop();
                          } else {
                            _player.start();
                          }
                        },
                      ),
                      Text(
                        actionsWidget.isSilenced ? 'Mute' : 'Volume up',
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
                          print('onPressed isMute: ${actionsWidget.isMuted}');

                          channelStr.sink.add('@at${userInfo.name}+//${userInfo.status}+//${userInfo.icon}+//${userInfo.micOn}');
                          if(userInfo.micOn == 'micOf'){
                            userInfo.micOn = 'micOn';
                          }
                          else{
                            userInfo.micOn = 'micOf';
                          }

                          actionsWidget.isMuted = !actionsWidget.isMuted;
                          if (actionsWidget.isMuted) {
                            stopRecord();
                          } else {
                            startRecord();
                          }

                          Timer(
                            Duration(milliseconds: 200),
                                () {
                              channelStr.sink.add('message to ignore');
                            },
                          );
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
          )
        ],
      ),
    );
  }

  usersConnected() {
    print('USERS CONNECTED METHOD');
    final actionsWidget = Provider.of<ActionsWidget>(context, listen: false);
    final userInfo = Provider.of<User>(context, listen: false);
    final meeting = Provider.of<Meeting>(context, listen: false);

    _userName = userInfo.name;
    _userStatus = userInfo.status;
    _userImage = userInfo.image;
    _userIcon = userInfo.icon;
    _userMic = userInfo.micOn;

    return WillPopScope(
      onWillPop: exitDialog,
      child: Scaffold(
        backgroundColor: ColorsNearVoice.primaryColor,
        body: Container(
          padding: const EdgeInsets.only(top: 0),
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
                      print('snapshot Client: $data');
                      if ((_listConnected
                                  .contains(data.substring(3)) ==
                              false) &&
                          (data.substring(0, 3) == '+us')) {
                        _listConnected
                            .add(data.substring(3));
                      } else if (data.substring(0, 3) == '--d') {
                        _listConnected.remove(data.substring(3));
                        List<String> _splitImg = data.split('+//');
                        Fluttertoast.showToast(
                            msg:
                                '${_splitImg[0].substring(3)} left the meeting',
                            toastLength: Toast.LENGTH_SHORT,
                            textColor: Colors.black);
                      }
                      _removeAll(data);
                      _remove(data,userInfo);
                      // _imageMuted(data);
                      mutedAll(data, actionsWidget);
                      mutedOne(data, actionsWidget, userInfo);
                      if (data == '?ru') {
                        channelStr.sink.add(
                            '.ok${userInfo.name}+//${userInfo.status}+//${userInfo.icon}');
                      }
                      print('list of connected client: $_listConnected');
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
                                Expanded(
                                  child: listConnected(actionsWidget),
                                ),
                              ],
                            ),
                          ),
                        ),

                        ///--------------------------------------
                        ///--------------------------------------
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removeAll(data){
    if (data == '*ex*') {
      Timer(Duration(seconds: 1), () {
        Navigator.of(context).pop();
      });
    }
  }

  void _remove(data,userInfo){
    if (data == '-rm${userInfo.name}+//${userInfo.status}') {
      Timer(Duration(seconds: 1), () {
        Navigator.of(context).pop();
      });
    }
  }

  Future mutedAll(data, actionsWidget) async{
    if (data == '*all') {
      print('muteAll isMute: ${actionsWidget.isMuted}');
      if (!actionsWidget.isMuted) {
        stopRecord();
        actionsWidget.isMuted = !actionsWidget.isMuted;
      }
    }
  }

  Future mutedOne(data, actionsWidget, userInfo) async {
    // if (data == '1mu${userInfo.name}+//${userInfo.status}+//${userInfo.icon}+//${userInfo.micOn}') {
    if (data == '1mu${userInfo.name}+//${userInfo.status}') {
      print('muteOne isMute: ${actionsWidget.isMuted}');
      if (!actionsWidget.isMuted) {
        stopRecord();
        actionsWidget.isMuted = !actionsWidget.isMuted;
      }

      userInfo.micOn = 'micOf';
      ///--------------------------------------------------------
      // if(data.substring(data.length - 5) == 'micOf'){
      //   int index = _listConnected.indexOf(data.substring(3));
      //   if(index >= 0) {
      //     String result = _listConnected[index].replaceAll(
      //         'micOf', 'micOn');
      //     _listConnected[index] = result;
      //   }
      // }
      // else if(data.substring(data.length - 5) == 'micOn'){
      //   int index = _listConnected.indexOf(data.substring(3));
      //   if(index >= 0) {
      //     String result = _listConnected[index].replaceAll(
      //         'micOn', 'micOf');
      //     _listConnected[index] = result;
      //   }
      // }
      ///------------------------------------------------------
      // print('onPressed isMute mutedone: ${actionsWidget.isMuted}');
      //
      // channelStr.sink.add('@at${userInfo.name}+//${userInfo.status}+//${userInfo.icon}+//${userInfo.micOn}');
      // if(userInfo.micOn == 'micOf'){
      //   userInfo.micOn = 'micOn';
      // }
      // else{
      //   userInfo.micOn = 'micOf';
      // }
      // Timer(
      //   Duration(milliseconds: 100), () {
      //   channelStr.sink.add('message to ignore');
      // },
      // );
    }
  }

  Future _imageMuted(data) async {
    if(data.substring(0, 3) == '@at'){
      if(data.substring(data.length - 5) == 'micOf'){
        int index = _listConnected.indexOf(data.substring(3));
        if(index >= 0) {
          String result = _listConnected[index].replaceAll(
              'micOf', 'micOn');
          _listConnected[index] = result;
        }
      }
      else if(data.substring(data.length - 5) == 'micOn'){
        int index = _listConnected.indexOf(data.substring(3));
        if(index >= 0) {
          String result = _listConnected[index].replaceAll(
              'micOn', 'micOf');
          _listConnected[index] = result;
        }
      }
      print('list replace: $_listConnected');
    }
  }

  listConnected(actionsWidget) {
    final meeting = Provider.of<Meeting>(context, listen: false);
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          collapsedHeight: 150,
          automaticallyImplyLeading: false,
          elevation: 0,
          pinned: true,
          backgroundColor: Colors.white,
          expandedHeight: MediaQuery.of(context).size.width * 0.7,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30))),
          flexibleSpace: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30),
                  ),
                  image: DecorationImage(
                      image: AssetImage(
                          'assets/connected-expanded-background.png'),
                      fit: BoxFit.cover),
                ),
                child: FlexibleSpaceBar(
                  titlePadding: EdgeInsets.only(left: 100, bottom: 20),
                  centerTitle: true,
                  title: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: '${meeting.name}\n',
                        // text: 'ga\n',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'OverpassBold'),
                      ),
                      TextSpan(
                          text: '${meeting.description}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            // fontWeight: FontWeight.bold
                          )),
                    ]),
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

                        if(_splitUser[2] == 'null'){
                          _splitUser[2] = 'assets/user.png';
                        }
                        return GestureDetector(
                          onTap: () {
                            _showInfoDialog(context, _splitUser);
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
                                        color: ColorsNearVoice.primaryColor.withOpacity(0.8),
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          fit: BoxFit.fill,
                                          image: _splitUser[3] != 'micOf'
                                              ? AssetImage(_splitUser[2])
                                              : AssetImage('assets/muted-user-icon.png'),
                                        ),
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
                                        // padding: EdgeInsets.all(15.0),
                                        child: Text(
                                          _splitUser[0],
                                          style: TextStyle(fontSize: 15),
                                        ),
                                      ),
                                      // height: 130,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                        'Do you want to leave the meeting?',
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
}

_showInfoDialog(context, List split) {
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
                child: Container(
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
                                      : AssetImage('assets/user.png')),
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
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontFamily: 'OverpassBold'),
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
            ],
          ),
        ),
      );
    },
  );
}
