// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:near_voice/model/env.dart';
// import 'package:near_voice/model/providers/meeting.dart';
// import 'package:provider/provider.dart';
// import 'package:web_socket_channel/io.dart';
//
// import 'create_meeting.dart';
//
// class MeetingNameServer extends StatefulWidget {
//   const MeetingNameServer({Key key}) : super(key: key);
//
//   @override
//   _MeetingNameState createState() => _MeetingNameState();
// }
//
// class _MeetingNameState extends State<MeetingNameServer> {
//   final channelStr = IOWebSocketChannel.connect("ws://${ipPhoneServer}:${PORT_STR}");
//   Timer _timer;
//
//   // sendNameDescriptionIp() {
//   //   final meeting = Provider.of<Meeting>(context,listen: false);
//   //
//   //   Timer(Duration(seconds: 3), () {
//   //     channelStr.sink.add('+nm${meeting.name},${meeting.description}/$ipPhone');
//   //   });
//   // }
//
//   @override
//   void initState() {
//     // sendNameDescriptionIp();
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     // _timer.cancel();
//     channelStr.sink.close();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final meeting = Provider.of<Meeting>(context,listen: false);
//     return Scaffold(
//       body: Center(
//           child: Text(
//         '${meeting.name}\n\n${meeting.description}',
//         style: TextStyle(fontSize: 18),
//       )),
//     );
//   }
// }
