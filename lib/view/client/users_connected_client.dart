// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';
//
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:hexcolor/hexcolor.dart';
// import 'package:near_voice/model/providers/actions_widget.dart';
// import 'package:near_voice/model/providers/meeting.dart';
// import 'package:near_voice/model/providers/user.dart';
// import 'package:near_voice/model/soundStream_method.dart';
// import 'package:near_voice/view/client/connect_meeting.dart';
// import 'package:provider/provider.dart';
// import 'package:web_socket_channel/io.dart';
// import 'package:web_socket_channel/status.dart' as status;
//
// import 'package:near_voice/model/env.dart';
// import 'package:near_voice/model/colors.dart';
//
// var ipRetrieves = ipEnter;
//
// class UserConnected extends StatefulWidget {
//   UserConnected({
//     Key key,
//   }) : super(key: key);
//
//   @override
//   _UserConnectedState createState() => _UserConnectedState();
// }
//
// class _UserConnectedState extends State<UserConnected>
//     with WidgetsBindingObserver {
//   final soundMethods = SoundStreamMethod();
//   var _nameMeet = '';
//   String _userName;
//   String _userStatus;
//   String _userImage;
//   String _userIcon;
//   List<String> _listConnected = [];
//
//   final channelStr = IOWebSocketChannel.connect("ws://$ipEnter:$PORT_STR");
//
//   @override
//   void initState() {
//     WidgetsBinding.instance.addObserver(this);
//     super.initState();
//     // soundMethods.startRecord();
//     // Timer(Duration(milliseconds: 200), () {
//     //   soundMethods.stopRecord();
//     // });
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     switch (state) {
//       case AppLifecycleState.inactive:
//         print(' on inactive');
//         break;
//       case AppLifecycleState.paused:
//         print('on paused');
//         // channelStr.sink.add('we are on pause');
//         break;
//       case AppLifecycleState.resumed:
//         print('on resumed');
//         break;
//       case AppLifecycleState.detached:
//         channelStr.sink.add('bye bye');
//         print('on detached');
//         break;
//       default:
//     }
//   }
//
//   @override
//   void dispose() {
//     channelStr.sink
//         .add('--d$_userName, $_userStatus+img$_userImage+img$_userIcon');
//     print('to clear: $_userName, $_userStatus');
//     _listConnected.clear();
//     channelStr.sink.close();
//
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final actionsWidget = Provider.of<ActionsWidget>(context, listen: false);
//     final userInfo = Provider.of<User>(context, listen: false);
//     final meeting = Provider.of<Meeting>(context, listen: false);
//     _userName = userInfo.name;
//     _userStatus = userInfo.status;
//     _userImage = userInfo.image;
//     _userIcon = userInfo.icon;
//
//     return WillPopScope(
//       onWillPop: exitDialog,
//       child: Scaffold(
//         backgroundColor: ColorsNearVoice.primaryColor,
//         body: Container(
//           padding: const EdgeInsets.only(top: 0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Expanded(
//                 child: StreamBuilder(
//                   stream: channelStr.stream,
//                   builder: (context, snapshot) {
//                     if (snapshot.hasData) {
//                       print('snapshot usersConnected: ${snapshot.data}');
//                       if ((_listConnected.contains(
//                                   (snapshot.data).toString().substring(3)) ==
//                               false) &&
//                           ((snapshot.data).toString().substring(0, 3) ==
//                               '+us')) {
//                         _listConnected
//                             .add((snapshot.data).toString().substring(3));
//                       } else if (snapshot.data.substring(0, 3) == '--d') {
//                         _listConnected.remove(snapshot.data.substring(3));
//                         List<String> _splitImg = snapshot.data.split('+img');
//                         Fluttertoast.showToast(
//                             msg:
//                                 '${_splitImg[0].substring(3)} left the meeting',
//                             toastLength: Toast.LENGTH_SHORT,
//                             textColor: Colors.black);
//                       }
//                       // if (snapshot.data.toString().substring(0, 3) == '+nm') {
//                       //   _nameMeet = snapshot.data;
//                       // }
//                       if (snapshot.data == '*ex*') {
//                         Timer(Duration(seconds: 1), () {
//                           Navigator.of(context).pop();
//                         });
//                       }
//
//                       if (snapshot.data == '*ax*') {
//                         Timer(Duration(seconds: 1), () {
//                           Navigator.of(context).pop();
//                         });
//                       }
//
//                       if (snapshot.data ==
//                           '-rm${userInfo.name}, ${userInfo.status}') {
//                         // actionsWidget.isRemoved = !actionsWidget.isRemoved;
//                         // if(actionsWidget.isRemoved) {
//                         //   Navigator.of(context).pop();
//                         // }
//                         // Navigator.of(context).pop();
//                         Timer(Duration(seconds: 1), () {
//                           Navigator.of(context).pop();
//                         });
//                         // actionsWidget.isRemoved = !actionsWidget.isRemoved;
//                       }
//
//                       mutedAll(snapshot.data, actionsWidget);
//                       mutedOne(snapshot.data, actionsWidget);
//                     }
//                     return Column(
//                       children: [
//                         Expanded(
//                           child: Container(
//                             decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(30),
//                                 color: Colors.white),
//                             child: Column(
//                               children: [
//                                 Expanded(
//                                   child: listConnected(actionsWidget),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//
//                         ///--------------------------------------
//                         Container(
//                           color: HexColor('#006059'),
//                           height: 80,
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceAround,
//                             children: [
//                               Container(
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     IconButton(
//                                       icon: Icon(
//                                         Icons.close_outlined,
//                                         size: 35,
//                                         color: Colors.white,
//                                       ),
//                                       onPressed: () {
//                                         exitDialog();
//                                       },
//                                     ),
//                                     Text(
//                                       'Exit',
//                                       style: TextStyle(color: Colors.white),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                               Container(
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     IconButton(
//                                       icon: Icon(
//                                         Icons.volume_off_outlined,
//                                         size: 35,
//                                         color: Colors.white,
//                                       ),
//                                       onPressed: () {},
//                                     ),
//                                     Text(
//                                       actionsWidget.isMuted
//                                           ? 'Mute'
//                                           : 'Volume up', //eye
//                                       style: TextStyle(color: Colors.white),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                               Container(
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     IconButton(
//                                       icon: Icon(
//                                         actionsWidget.isMuted
//                                             ? Icons.mic_off_outlined
//                                             : Icons.mic_outlined,
//                                         size: 35,
//                                         color: Colors.white,
//                                       ),
//                                       onPressed: () {
//                                         print('onPressed isMute: ${actionsWidget.isMuted}');
//                                         ///-------------
//                                         // channelStr.sink.add(
//                                         //     '<up$_userName, $_userStatus+img${userInfo.image}'); //ojo
//                                         // print('change img: ${userInfo.name}');
//                                         ///---------------------------
//
//                                         if(actionsWidget.isMuted){
//                                           soundMethods.startRecord();
//                                           actionsWidget.isMuted =
//                                               !actionsWidget.isMuted;
//                                         }
//                                         else{
//                                           soundMethods.stopRecord();
//                                           actionsWidget.isMuted =
//                                               !actionsWidget.isMuted;
//                                         }
//                                         // actionsWidget.isMuted =
//                                         //     !actionsWidget.isMuted;
//                                         // if (actionsWidget.isMuted) {//true
//                                         //   print('muted client');
//                                         //   soundMethods.stopRecord();
//                                         // } else {//false
//                                         //   print('talking client');
//                                         //   soundMethods.startRecord();
//                                         // }
//                                       },
//                                     ),
//                                     Text(
//                                       actionsWidget.isMuted
//                                           ? 'Mic Off'
//                                           : 'Mic On',
//                                       style: TextStyle(color: Colors.white),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void mutedAll(data, actionsWidget) {
//     if (data == '*muted') {
//       // actionsWidget.isMuted = !actionsWidget.isMuted;
//       if (!actionsWidget.isMuted) {
//         soundMethods.stopRecord();
//         // actionsWidget.isMuted = !actionsWidget.isMuted;
//
//         // soundMethods.startRecord();
//       }
//     }
//   }
//
//   void mutedOne(data, actionsWidget) {
//     final userInfo = Provider.of<User>(context);
//     if (data == '1mu${userInfo.name}, ${userInfo.status}') {
//       print('muteOne isMute: ${actionsWidget.isMuted}');
//
//       if (!actionsWidget.isMuted) {
//         soundMethods.stopRecord();
//
//         actionsWidget.isMuted = !actionsWidget.isMuted;
//         data = null;
//
//         // Timer(
//         //   Duration(seconds: 1),
//         //   () {
//         //     actionsWidget.isMuted = !actionsWidget.isMuted;
//         //   },
//         // );
//       }
//     }
//   }
//
//   listConnected(actionsWidget) {
//     final meeting = Provider.of<Meeting>(context, listen: false);
//     return CustomScrollView(
//       slivers: [
//         SliverAppBar(
//           collapsedHeight: 150,
//           automaticallyImplyLeading: false,
//           elevation: 0,
//           pinned: true,
//           backgroundColor: Colors.white,
//           expandedHeight: MediaQuery.of(context).size.width * 0.7,
//           shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(30), topRight: Radius.circular(30))),
//           flexibleSpace: Stack(
//             alignment: Alignment.bottomRight,
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.only(
//                     topRight: Radius.circular(30),
//                     topLeft: Radius.circular(30),
//                   ),
//                   image: DecorationImage(
//                       image: AssetImage(
//                           'assets/connected-expanded-background.png'),
//                       fit: BoxFit.cover),
//                 ),
//               ),
//               Positioned(
//                 top: 160,
//                 right: 30,
//                 child: (meeting.name != null)
//                     ? Text(
//                         '${meeting.name}',
//                         style: TextStyle(
//                             color: ColorsNearVoice.primaryColor,
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold),
//                       )
//                     : Text(
//                         'Meeting name',
//                         style: TextStyle(
//                             color: ColorsNearVoice.primaryColor,
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold),
//                       ),
//               ),
//               Positioned(
//                 top: 190,
//                 right: 30,
//                 child: (meeting.description != null)
//                     ? Text(
//                         '${meeting.description}',
//                         style: TextStyle(
//                             color: ColorsNearVoice.primaryColor, fontSize: 24),
//                       )
//                     : Text(
//                         'Description',
//                         style: TextStyle(
//                             color: ColorsNearVoice.primaryColor, fontSize: 24),
//                       ),
//               )
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
//                       physics: NeverScrollableScrollPhysics(),
//                       shrinkWrap: true,
//                       itemBuilder: (BuildContext context, index) {
//                         List<String> _splitUser =
//                             _listConnected[index].split('+img');
//                         // print('split 0: ${_splitUser[0]}');
//                         // print('split 1: ${_splitUser[1]}');
//                         // print('split 2: ${_splitUser[2]}');
//                         return GestureDetector(
//                           onTap: () {
//                             print('item selected: ${_listConnected[index]}');
//                           },
//                           child: ListTile(
//                             title: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Container(
//                                     height: 60,
//                                     width: 60,
//                                     decoration: BoxDecoration(
//                                       shape: BoxShape.circle,
//                                       image: DecorationImage(
//                                         fit: BoxFit.fill,
//                                         image: _splitUser[1] != 'null' &&
//                                                 actionsWidget.isImgMuted
//                                             ? MemoryImage(
//                                                 base64Decode(_splitUser[1]),
//                                               )
//                                             // : actionsWidget.isMuted
//                                             //     ? AssetImage('assets/user2.jpg')
//                                             : _splitUser[2] != 'null'
//                                                 ? AssetImage(_splitUser[2])
//                                                 : AssetImage('assets/user.png'),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                       border: Border.all(width: 0.5),
//                                       borderRadius:
//                                           BorderRadius.all(Radius.circular(30)),
//                                     ),
//                                     child: Padding(
//                                       padding: EdgeInsets.all(10.0),
//                                       child: Text(
//                                         _splitUser[0],
//                                         style: TextStyle(fontSize: 15),
//                                       ),
//                                     ),
//                                     // height: 130,
//                                     height: 45,
//                                   ),
//                                 ),
//                               ],
//                             ),
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
//   Future<bool> exitDialog() {
//     final heightDialog = MediaQuery.of(context).size.height * 0.22;
//     final widthDialog = MediaQuery.of(context).size.width * 0.65;
//     showDialog(
//       context: context,
//       builder: (context) {
//         return Center(
//           child: Container(
//             width: widthDialog,
//             height: heightDialog,
//             decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(15),
//                 color: ColorsNearVoice.primaryColor),
//             child: Column(
//               children: [
//                 Expanded(
//                   flex: 2,
//                   child: Container(
//                     child: Center(
//                       child: Text(
//                         'Do you want to leave the meeting?',
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 14,
//                             // fontFamily:
//                             decoration: TextDecoration.none),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   flex: 1,
//                   child: Container(
//                     // color: Colors.amberAccent,
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed: () {
//                               Navigator.of(context).pop();
//                               Navigator.of(context).pop();
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
//                               // onPrimary: Colors.amberAccent
//                             ),
//                             child: Text('Yes'),
//                           ),
//                         ),
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed: () {
//                               Navigator.of(context).pop(false);
//                             },
//                             style: ElevatedButton.styleFrom(
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.only(
//                                     bottomRight: Radius.circular(15),
//                                   ),
//                                 ),
//                                 elevation: 7,
//                                 minimumSize:
//                                     Size(widthDialog / 2, heightDialog / 3),
//                                 // primary: ColorsNearVoice.primaryColor,
//                                 primary: ColorsNearVoice.primaryColor,
//                                 onPrimary: Colors.white),
//                             child: Text('No'),
//                           ),
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
// }
