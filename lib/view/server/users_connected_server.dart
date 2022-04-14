// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';
// import 'dart:ffi';
// import 'dart:math';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:hexcolor/hexcolor.dart';
// import 'package:near_voice/model/colors.dart';
// import 'package:near_voice/model/providers/actions_widget.dart';
// import 'package:near_voice/model/providers/meeting.dart';
// import 'package:near_voice/model/providers/user.dart';
//
// import 'package:provider/provider.dart';
// import 'package:web_socket_channel/io.dart';
//
// import 'create_meeting.dart';
// import 'package:near_voice/model/env.dart';
//
// class UserConnectedServer extends StatefulWidget {
//   // final channelStr;
//
//   UserConnectedServer({
//     Key key,
//     // @required this.channelStr,
//   }) : super(key: key);
//
//   @override
//   _UserConnectedState createState() => _UserConnectedState();
// }
//
// class _UserConnectedState extends State<UserConnectedServer>
//     with WidgetsBindingObserver {
//   final channelStr =
//       IOWebSocketChannel.connect("ws://$ipPhoneServer:$PORT_STR");
//
//   // Map<int, List<String>> _mapConnected = {};
//   List<String> _listConnected = [];
//   List<String> _listConnectedTemp = [];
//   String _userName;
//   String _userStatus;
//   String _userImage;
//   String _userIcon;
//
//   @override
//   void initState() {
//     final userInfo = Provider.of<User>(context, listen: false);
//     WidgetsBinding.instance.addObserver(this);
//
//     // _mapConnected.putIfAbsent(0,
//     //     () => [userInfo.name, userInfo.status, userInfo.image, userInfo.icon]);
//
//     _listConnected
//         .add('${userInfo.name}+//${userInfo.status}+//${userInfo.icon}');
//
//     _listConnectedTemp
//         .add('${userInfo.name}+//${userInfo.status}+//${userInfo.icon}');
//
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     channelStr.sink
//         .add('--d$_userName+//$_userStatus+//$_userImage+//$_userIcon');
//
//     Timer(Duration(milliseconds: 100), () {
//       channelStr.sink.add('*ex*');
//     });
//     Timer(Duration(milliseconds: 300), () {
//       channelStr.sink.close();
//     });
//
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     print('STATE SERVER: $state');
//     switch (state) {
//       case AppLifecycleState.resumed:
//         print('ON RESUME');
//         break;
//       case AppLifecycleState.paused:
//         print('ON PAUSE');
//         break;
//       case AppLifecycleState.detached:
//         print('DETACHED');
//         break;
//       default:
//         break;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     print('BUILD users_connected_server');
//     final actionsWidget = Provider.of<ActionsWidget>(context, listen: false);
//     final userInfo = Provider.of<User>(context, listen: false);
//     final meeting = Provider.of<Meeting>(context, listen: false);
//
//     _userName = userInfo.name;
//     _userStatus = userInfo.status;
//     _userImage = userInfo.image;
//
//     // String data;
//
//     return Container(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Expanded(
//             child: StreamBuilder(
//               stream: channelStr.stream,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.done) {
//                   print('ConnectionState => done');
//                   Navigator.of(context).pop();
//                 }
//
//                 if (snapshot.hasError) {
//                   print('ConnectionState => error');
//                   Navigator.of(context).pop();
//                 }
//
//                 if (snapshot.hasData) {
//                   print('snapshot Server: ${snapshot.data}');
//
//                   if (snapshot.data == '>hi') {
//                     channelStr.sink.add(
//                         '+nm${meeting.name}//${meeting.description}//$ipPhoneServer//${meeting.image}');
//                   }
//
//                   if ((_listConnected.contains((snapshot.data).substring(3)) ==
//                           false) &&
//                       ((snapshot.data).substring(0, 3) == '@ad')) {
//                     _listConnected.add((snapshot.data).toString().substring(3));
//                     sendUsers();
//                   } else if (snapshot.data.substring(0, 3) == '--d') {
//                     _listConnected.remove(snapshot.data.substring(3));
//                     List<String> splitImg = snapshot.data.split('+//');
//                     Fluttertoast.showToast(
//                         msg: '${splitImg[0].substring(3)} left the meeting',
//                         toastLength: Toast.LENGTH_SHORT,
//                         textColor: Colors.black);
//                   }
//
//                   if ((_listConnectedTemp
//                               .contains((snapshot.data).substring(3)) ==
//                           false) &&
//                       (snapshot.data).substring(0, 3) == '.ok') {
//                     _listConnectedTemp.add((snapshot.data).substring(3));
//                   }
//
//                   if (snapshot.data == '?ru') {
//                     Timer(Duration(seconds: 10), () {
//                       print('getting in after 6 seconds');
//                       _listConnected.removeWhere(
//                           (element) => !_listConnectedTemp.contains(element));
//                     });
//                   }
//                   // _listConnectedTemp.clear();
//                   // _listConnectedTemp.add(
//                   //     '${userInfo.name}, ${userInfo.status}+img${userInfo.image}+img${userInfo.icon}');
//                 }
//                 return listConnected(actionsWidget);
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   listConnected(actionsWidget) {
//     final meeting = Provider.of<Meeting>(context, listen: false);
//     return CustomScrollView(
//       slivers: <Widget>[
//         SliverAppBar(
//           collapsedHeight: 150,
//           expandedHeight: MediaQuery.of(context).size.width * 0.7,
//           // floating: true,
//           automaticallyImplyLeading: false,
//           elevation: 0,
//           pinned: true,
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(30), topRight: Radius.circular(30))),
//           flexibleSpace: Stack(
//             alignment: Alignment.bottomRight,
//             children: [
//               Container(
//                 // height: 390,
//                 // width: double.infinity,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.only(
//                     topRight: Radius.circular(30),
//                     topLeft: Radius.circular(30),
//                   ),
//                   image: DecorationImage(
//                       image: AssetImage('assets/created-background.png'),
//                       fit: BoxFit.cover),
//                 ),
//                 // child: Stack(
//                 //   children: [ Positioned(
//                 //       top: 160,
//                 //       right: 60,
//                 //       child: Text('gaaa',style: TextStyle(color: HexColor('#002B33'),fontSize: 24))),
//                 //   ]
//                 // ),
//                 ///------------------
//                 child: FlexibleSpaceBar(
//                   titlePadding: EdgeInsets.only(left: 100, bottom: 20),
//                   // collapseMode: CollapseMode.none,
//                   centerTitle: true,
//                   title: meeting.name != null
//                       ? RichText(
//                           text: TextSpan(children: [
//                           TextSpan(
//                             text: '${meeting.name}\n',
//                             style: TextStyle(
//                                 color: HexColor('#002B33'),
//                                 fontSize: 18,
//                               fontFamily: 'OverpassBold'
//                                 ),
//                           ),
//                           TextSpan(
//                               text: '${meeting.description}',
//                               style: TextStyle(
//                                   color: HexColor('#002B33'),
//                                   fontSize: 16,
//                                   // fontWeight: FontWeight.bold
//                               )
//                           )
//                         ]))
//                       // TextSpan(
//                       //         // '${meeting.name}\n${meeting.description}',
//                       //   text: '${meeting.name}\n${meeting.description}',
//                       //         style: TextStyle(
//                       //             color: HexColor('#002B33'),
//                       //             fontSize: 18,
//                       //             fontWeight: FontWeight.bold),
//                       //       )
//                       : Text(
//                           'Meeting name',
//                           style: TextStyle(
//                             color: HexColor('#002B33'),
//                             fontSize: 20,
//                             // fontWeight: FontWeight.bold
//                           ),
//                         ),
//                 ),
//               ),
//               // Positioned(
//               //   top: 160,
//               //   right: 30,
//               //   child: (meeting.name != null)
//               //       ? Text(
//               //           '${meeting.name}',
//               //           style: TextStyle(
//               //               color: HexColor('#002B33'),
//               //               fontSize: 24,
//               //               fontWeight: FontWeight.bold),
//               //         )
//               //       : Text(
//               //           'Meeting name',
//               //           style: TextStyle(
//               //             color: HexColor('#002B33'),
//               //             fontSize: 24,
//               //             // fontWeight: FontWeight.bold
//               //           ),
//               //         ),
//               // ),
//               // Positioned(
//               //   top: 190,
//               //   right: 30,
//               //   child: (meeting.description != null)
//               //       ? Text(
//               //           '${meeting.description}',
//               //           style:
//               //               TextStyle(color: HexColor('#002B33'), fontSize: 20),
//               //         )
//               //       : Text(
//               //           'Description',
//               //           style: TextStyle(
//               //               color: ColorsNearVoice.primaryColor, fontSize: 20),
//               //         ),
//               // )
//             ],
//           ),
//         ),
//         SliverList(
//           delegate: SliverChildListDelegate(
//             [
//               new Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   ListView.builder(
//                       itemCount: _listConnected.length,
//                       // physics: NeverScrollableScrollPhysics(),
//                       shrinkWrap: true,
//                       itemBuilder: (BuildContext context, index) {
//                         List<String> _splitUser =
//                             _listConnected[index].split('+//');
//                         return GestureDetector(
//                           onTap: () {
//                             _showMuteDialog(context, actionsWidget,
//                                 _listConnected[index], _splitUser);
//                           },
//                           child: ListTile(
//                             title: Padding(
//                               padding: const EdgeInsets.only(
//                                   top: 20, left: 30, right: 30),
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Padding(
//                                     padding: const EdgeInsets.only(right: 15),
//                                     child: Container(
//                                       height: 70,
//                                       width: 70,
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         image: DecorationImage(
//                                             fit: BoxFit.fill,
//                                             image: _splitUser[2] != 'null'
//                                                 ? AssetImage(_splitUser[2])
//                                                 : AssetImage('assets/user.png')
//                                             // ? MemoryImage(base64Decode(
//                                             //     _mapConnected[index][2]),scale: 90.0)
//                                             // : _mapConnected[index][3] != null
//                                             //     ? AssetImage(
//                                             //         // 'assets/user.png')
//                                             //         _mapConnected[index][3])
//                                             //     : AssetImage(
//                                             //         'assets/user.png')
//                                             ),
//                                       ),
//                                     ),
//                                   ),
//                                   Expanded(
//                                     child: Container(
//                                       decoration: BoxDecoration(
//                                         border: Border.all(width: 0.5),
//                                         borderRadius: BorderRadius.all(
//                                             Radius.circular(30)),
//                                       ),
//                                       child: Padding(
//                                         padding: EdgeInsets.symmetric(
//                                             vertical: 10, horizontal: 25),
//                                         // padding: EdgeInsets.all(10.0),
//                                         child: Text(
//                                           // '${_mapConnected[index][0]}',
//                                           _splitUser[0],
//                                           style: TextStyle(fontSize: 15),
//                                         ),
//                                       ),
//                                       // height: 390,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             // subtitle: Text('${_mapConnected[key]}',),
//                           ),
//                         );
//                       }),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   _showMuteDialog(context, actionsWidget, list, split) {
//     final heightDialog = MediaQuery.of(context).size.height * 0.23; //0.22
//     final widthDialog = MediaQuery.of(context).size.width * 0.75; //0.65
//
//     return showDialog(
//       context: context,
//       builder: (context) {
//         return Center(
//           child: Container(
//             width: widthDialog,
//             height: heightDialog,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(15),
//               // color: ColorsNearVoice.primaryColor.withOpacity(0.8),
//               color: ColorsNearVoice.primaryColor,
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   flex: 2,
//                   child: Container(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Center(
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.only(right: 8, left: 20),
//                             child: Container(
//                               height: 60,
//                               width: 60,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 image: DecorationImage(
//                                     fit: BoxFit.fill,
//                                     image: split[2] != 'null'
//                                         ? AssetImage(split[2])
//                                         : AssetImage('assets/user.png')),
//                               ),
//                             ),
//                           ),
//                           Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 split[0],
//                                 style: TextStyle(
//                                     color: Colors.white, fontSize: 18),
//                               ),
//                               Text(
//                                 split[1],
//                                 style: TextStyle(
//                                     color: Colors.white70, fontSize: 18),
//                               ),
//                             ],
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   flex: 1,
//                   child: Container(
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed: () {
//                               channelStr.sink
//                                   .add('1mu${split[0]}+//${split[1]}');
//                               Navigator.of(context).pop();
//                               Timer(
//                                 Duration(milliseconds: 500),
//                                 () {
//                                   channelStr.sink.add('message to ignore');
//                                 },
//                               );
//                             },
//                             style: ElevatedButton.styleFrom(
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.only(
//                                   bottomLeft: Radius.circular(15),
//                                 ),
//                               ),
//                               elevation: 7,
//                               primary: ColorsNearVoice.thirdColor,
//                               minimumSize:
//                                   Size(widthDialog / 2, heightDialog / 3),
//                             ),
//                             child: Text('Mic off'),
//                           ),
//                         ),
//                         Expanded(
//                           child: ElevatedButton(
//                               onPressed: () {
//                                 channelStr.sink
//                                     .add('-rm${split[0]}+//${split[1]}');
//                                 Navigator.of(context).pop();
//                               },
//                               style: ElevatedButton.styleFrom(
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.only(
//                                       bottomRight: Radius.circular(15),
//                                     ),
//                                   ),
//                                   elevation: 7,
//                                   minimumSize:
//                                       Size(widthDialog / 2, heightDialog / 3),
//                                   primary: ColorsNearVoice.primaryColor,
//                                   onPrimary: Colors.white),
//                               child: Text('Remove')),
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Future sendUsers() async {
//     for (String m in _listConnected) {
//       await new Future.delayed(new Duration(milliseconds: 500));
//       channelStr.sink.add('+us$m');
//     }
//   }
// }
