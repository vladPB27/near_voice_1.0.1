import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_ip/get_ip.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:near_voice/model/colors.dart';
import 'package:near_voice/model/providers/meeting.dart';
import 'package:near_voice/model/providers/user.dart';
import 'package:near_voice/view/login.dart';
import 'package:near_voice/widgets/Image_customize_server.dart';
import 'package:provider/provider.dart';

import 'package:web_socket_channel/io.dart';
import 'package:near_voice/model/env.dart';

var ipPhoneServer;

class CreateMeeting extends StatefulWidget {
  const CreateMeeting({Key key}) : super(key: key);

  @override
  _CreateMeetingState createState() => _CreateMeetingState();
}

class _CreateMeetingState extends State<CreateMeeting> {
  String _ip = 'unknown';
  final meetingNameController = TextEditingController();
  final meetingDescController = TextEditingController();
  final formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String ipAddress;
    try {
      ipAddress = await GetIp.ipAddress;
    } on PlatformException {
      ipAddress = 'Failed to get ipAddress';
    }

    if (!mounted) return;
    setState(() {
      _ip = ipAddress;
      ipPhoneServer = _ip;
      print("check ip: $ipPhoneServer");
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('CREATE MEETING SCREEN');
    final userInfo = Provider.of<User>(context, listen: false);
    final meeting = Provider.of<Meeting>(context, listen: false);

    return Scaffold(
      backgroundColor: ColorsNearVoice.primaryColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Create',
          style: TextStyle(fontFamily: 'OverpassBold', fontSize: 24),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: ColorsNearVoice.primaryColor,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30), color: Colors.white),
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ImageCustomizeServer(),
                    ),
                  ),
                  Expanded(
                    child: Form(
                      key: formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                                  EdgeInsets.only(top: 20, left: 50, right: 50),
                              child: Container(
                                child: TextFormField(
                                  controller: meetingNameController,
                                  validator: (value) => value.trim().length == 0
                                      ? 'Enter a name to start the meeting'
                                      : null,
                                  decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 15, horizontal: 25),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30.0))),
                                      hintText: 'Meeting name'),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: 10, left: 50, right: 50, top: 20),
                              child: Container(
                                child: TextFormField(
                                  controller: meetingDescController,
                                  validator: (value) => value.trim().length == 0
                                      ? 'Enter a description to start the meeting'
                                      : null,
                                  decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 15, horizontal: 25),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30.0))),
                                      hintText: 'Description'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: ColorsNearVoice.primaryColor,
            height: 80,
            // width: 340,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                          icon: Icon(
                            Icons.add_circle_outline,
                            size: 35,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            final form = formKey.currentState;
                            if (form.validate()) {
                              meeting.name = meetingNameController.text;
                              meeting.description = meetingDescController.text;

                              _runServerAudio();
                              _runServerString();
                              // userInfo.micOn == 'micOf';

                              Navigator.of(context)
                                  .pushNamed('/create_loading');
                            }
                          }),
                      Text(
                        'Create',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.people_alt_outlined,
                          size: 35,
                          color: Colors.white70,
                        ),
                        onPressed: () {},
                      ),
                      Text(
                        'Connect',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _runServerAudio() async {
  final connections = Set<WebSocket>();
  HttpServer.bind(ipPhoneServer.toString(), PORT_AUDIO).then(
      (HttpServer server) {
    //own ip address
    print('[+]WebSocket listening at -- ws://$ipPhoneServer:$PORT_AUDIO/');
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

void _runServerString() async {
  final connections = Set<WebSocket>();
  HttpServer.bind(ipPhoneServer.toString(), PORT_STR).then((HttpServer server) {
    // HttpServer.bind(ipPhoneServer.toString(), PORT_STR)
    //     .timeout(Duration(seconds: 15))
    //     .then((HttpServer server) {
    print('[+]WebSocket str listening at -- ws://$ipPhoneServer:$PORT_STR/');
    server.listen((HttpRequest request) {
      WebSocketTransformer.upgrade(request).then((WebSocket ws) {
        connections.add(ws);
        print('[+]Connected STR');
        ws.listen(
          (data) {
            // Broadcast data to all other clients
            for (var conn in connections) {
              if (conn != ws && conn.readyState == WebSocket.open) {
                conn.add(data);
                // print('serverData: $data');
              }
            }
          },
          onDone: () {
            connections.remove(ws);

            // for (var conn in connections) {
            //   if (conn != ws && conn.readyState == WebSocket.open) {
            //     Timer(Duration(milliseconds: 300), () {
            //       conn.add('?ru');
            //     });
            //     // print('serverData: $data');
            //   }
            // }
            print('[-]Disconnected STR');
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
