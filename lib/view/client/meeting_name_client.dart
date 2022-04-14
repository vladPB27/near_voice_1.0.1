// import 'package:flutter/material.dart';
// import 'package:near_voice/view/connect_meeting.dart';
// import 'package:near_voice/env.dart';
// import 'package:web_socket_channel/io.dart';
//
// var ipRetrieves = ipEnter;
//
// class MeetingName extends StatefulWidget {
//   const MeetingName({Key key}) : super(key: key);
//
//   @override
//   _MeetingNameState createState() => _MeetingNameState();
// }
//
// class _MeetingNameState extends State<MeetingName> {
//   final channelStr =
//       // IOWebSocketChannel.connect("ws://${ipRetrieves}:${PORT_STR}");
//       IOWebSocketChannel.connect("ws://${ipEnter}:${PORT_STR}");
//   var nameMeet = '';
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     channelStr.sink.close();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: StreamBuilder(
//         stream: channelStr.stream,
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             print('data connecting: ${snapshot.data}');
//             if (snapshot.data.toString().substring(0, 4) == 'name') {
//               nameMeet = snapshot.data;
//               print('name meet: $nameMeet');
//             }
//           } else {
//             // print('no data');
//             return Center(
//               child: Text(
//                 'Meeting name\n\nDescription',
//                 style: TextStyle(fontSize: 18),
//               ),
//             );
//           }
//           return Center(
//             child: (nameMeet.length >= 4)
//                 ? Text(
//                     nameMeet.substring(4),
//                     style: TextStyle(fontSize: 18),
//                   )
//                 : Center(
//                     child: Text(
//                       'Meeting name\n\nDescription',
//                       style: TextStyle(fontSize: 18),
//                     ),
//                   ),
//           );
//         },
//       ),
//     );
//   }
// }
