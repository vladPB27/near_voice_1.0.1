import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_ip/get_ip.dart';
import 'package:near_voice/model/colors.dart';
import 'package:near_voice/model/env.dart';
import 'package:near_voice/model/providers/meeting.dart';
import 'package:near_voice/model/providers/user.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:io' as Io;

var ipEnter;

class ConnectMeeting extends StatefulWidget {
  ConnectMeeting({
    Key key,
  }) : super(key: key);

  @override
  _ConnectMeetingState createState() => _ConnectMeetingState();
}

class _ConnectMeetingState extends State<ConnectMeeting> {
  String _ip = 'unknown';
  var nameToConnect;
  var ipFromServer;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    listMeetings.clear();
    super.dispose();
  }

  Future _searchMeetings() async {
    setState(() {
      listMeetings.clear();
    });

    String ipCurrent = await GetIp.ipAddress;
    List<String> ipSplit = ipCurrent.split('.');

    for (int i = 0; i < 256; i++) {
      String ipTest = '${ipSplit[0]}.${ipSplit[1]}.${ipSplit[2]}.$i';

      final channelStr =
          IOWebSocketChannel.connect(Uri.parse("ws://$ipTest:$PORT_STR"));
      channelStr.sink.add('>hi');
      channelStr.stream.listen((event) async {
        print('data connectMeeting: $event');
        if ((listMeetings.contains(event.substring(3)) == false) &&
            (event.substring(0, 3) == '+nm')) {
          setState(() {
            // Future.delayed(Duration(seconds: 2));
            listMeetings.add(event.substring(3));
          });
        }
        print('ip list: $listMeetings');
        Timer(Duration(seconds: 3), () {
          channelStr.sink.close();
        });
      }, onError: (error, StackTrace stacktrace) {
        channelStr.sink.close();
      }, onDone: () {
        channelStr.sink.close();
      }, cancelOnError: true);
    }
  }

  Future<void> initPlatformState() async {
    String ipAddress;
    var ipPhoneCurrent;
    try {
      ipAddress = await GetIp.ipAddress;
    } on PlatformException {
      ipAddress = 'Failed to get ipAddress';
    }

    if (!mounted) return;
    setState(() {
      _ip = ipAddress;
      ipPhoneCurrent = _ip;
      print("check ip: $ipPhoneCurrent");
    });
  }


  @override
  Widget build(BuildContext context) {
    print('CONNECT SCREEN');
    return Scaffold(
      backgroundColor: ColorsNearVoice.primaryColor,
      appBar: AppBar(
        title: Text(
          'Connect',
          style: TextStyle(fontFamily: 'OverpassBold', fontSize: 24),
        ),
        backgroundColor: ColorsNearVoice.primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: RefreshIndicator(
        // onRefresh: _refreshData,
        onRefresh: _searchMeetings,
        backgroundColor: Colors.white,
        color: ColorsNearVoice.primaryColor,
        strokeWidth: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.15,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(30),
                          topLeft: Radius.circular(30),
                        ),
                        image: DecorationImage(
                            image: AssetImage('assets/connect-background.png'),
                            fit: BoxFit.cover),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(0),
                        child: listMeetings.isNotEmpty ? showListMeetings() : showListMeetingsEmpty(),
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
                            Icons.person_outline,
                            size: 35,
                            color: Colors.white70,
                          ),
                          onPressed: () {},
                        ),
                        Text(
                          'Profile',
                          style: TextStyle(color: Colors.white70),
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
                            Icons.add_circle_outline,
                            size: 35,
                            color: Colors.white70,
                          ),
                          onPressed: () {},
                        ),
                        Text(
                          'Create',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                  /// connect to meeting
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.people_alt_outlined,
                            size: 35,
                            color: Colors.white,
                          ),
                          onPressed: () {},
                        ),
                        Text(
                          'Connect',
                          style: TextStyle(color: Colors.white),
                        ),
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

  List<String> listMeetings = [];

  ListView showListMeetings() {
    final meeting = Provider.of<Meeting>(context, listen: false);
    List<Widget> listWidget = [];

    for (String message in listMeetings) {
      List<String> _splitIp = message.split('//');

      listWidget.add(
        ListTile(
          onTap: () {
            meeting.name = _splitIp[0];
            meeting.description = _splitIp[1];
            ipEnter = _splitIp[2];

            if (ipEnter != null) {
              _joinDialog(meeting.name);
            }
          },
          title: Padding(
            padding: const EdgeInsets.only(left: 40, right: 40, top: 30),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        image: _splitIp[3] != 'null'
                            ? AssetImage(_splitIp[3])
                            : AssetImage('assets/meeting-1.png'),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    // height: 40,
                    decoration: BoxDecoration(
                        border: Border.all(width: 0.5),
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    child: Padding(
                      // padding: EdgeInsets.all(8.0),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                      child: Text(
                        _splitIp[0],
                        // style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return ListView(
      children: listWidget,
    );
  }

  ListView showListMeetingsEmpty() {
    final meeting = Provider.of<Meeting>(context, listen: false);
    List<Widget> listWidget = [];

    for (String message in listMeetings) {
      List<String> _splitIp = message.split('//');

      listWidget.add(
        ListTile(
          onTap: () {
          },
          title: Padding(
            padding: const EdgeInsets.only(left: 40, right: 40, top: 30),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    // height: 40,
                    decoration: BoxDecoration(
                        border: Border.all(width: 0.5),
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    child: Padding(
                      // padding: EdgeInsets.all(8.0),
                      padding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                      child: Text(
                        'nothing',
                        // style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return ListView(
      children: listWidget,
    );
  }


  Future<bool> _joinDialog(String name) {
    final userInfo = Provider.of<User>(context, listen: false);
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
                color: ColorsNearVoice.primaryColor),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        'Do you want to join to $name?',
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
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();

                              final channelStr = IOWebSocketChannel.connect(
                                  "ws://$ipEnter:$PORT_STR");
                              // channelStr.sink.add(
                              //     '@ad${userInfo.name}+//${userInfo.status}+//${userInfo.image}+//${userInfo.icon}');

                              userInfo.micOn = 'micOf';
                              channelStr.sink.add(
                                  '@ad${userInfo.name}+//${userInfo.status}+//${userInfo.icon}+//${userInfo.micOn}');

                              channelStr.sink.close();
                              Navigator.of(context)
                                  .pushReplacementNamed('/meetjoin');
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
                              // onPrimary: Colors.white
                            ),
                            child: Text('Yes',style: TextStyle(fontFamily: 'OverpassBold',
                                fontSize: 18
                            ),),
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
                              child: Text('No',style: TextStyle(fontFamily: 'OverpassBold',
                                  fontSize: 18
                              ))),
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
