import 'dart:convert';
import 'dart:io';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:near_voice/model/colors.dart';
import 'package:near_voice/model/providers/user.dart';
import 'package:near_voice/view/login.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  _InitialPageState createState() => _InitialPageState();
}

class _InitialPageState extends State<Home> with AfterLayoutMixin {
  @override
  void afterFirstLayout(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  //i will improve this code
  //TODO retomando informes
  final testController = TextEditingController();

  String _ip = "unknown";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userInfo = Provider.of<User>(context);

    File _imageReal;
    if (userInfo.imageReal != null) {
      setState(() {
        _imageReal = File(userInfo.imageReal.path);
      });
    }

    //TODO RAMA para practicas
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 30, bottom: 30, right: 30, left: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        //probando Wrap en lugar de Row
                        child: Wrap(
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: userInfo.imageReal != null
                                  ? Image.file(
                                      _imageReal,
                                      fit: BoxFit.cover,
                                    ).image
                                  : userInfo.icon != null
                                      ? AssetImage(userInfo.icon)
                                      : AssetImage('assets/user-3.png'),
                            ),
                          ),
                        ),
                        // Text('PRACTICAS PRE PRO'),
                        Text(
                          '  Hi, ${userInfo.name}',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        )
                      ],
                    )),
                    // to reset login
                    // IconButton(
                    //     icon: Icon(Icons.logout),
                    //     onPressed: () async {
                    //       final SharedPreferences shared =
                    //           await SharedPreferences.getInstance();
                    //       shared.remove('name');
                    //       shared.remove('status');
                    //
                    //       Navigator.of(context).pushReplacement(
                    //           MaterialPageRoute(builder: (_) => Login()));
                    //     }),
                    IconButton(
                      icon: Icon(
                        Icons.error_outline,
                        color: ColorsNearVoice.primaryColor,
                        size: 30,
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          '/info_popup',
                        );
                      },
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 25, left: 25, top: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed(
                                '/profile',
                              );
                            },
                            child: Image.asset(
                                'assets/profile-home-background.png'),
                          ),
                          Positioned(
                            right: 55,
                            child: Text(
                              'Profile',
                              style: TextStyle(
                                  fontFamily: 'OverpassBold',
                                  color: Colors.white,
                                  fontSize: 24),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 20, bottom: 30, right: 25, left: 25),
                child: Row(
                  children: [
                    Expanded(
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed('/createMeeting');
                            },
                            child: Image.asset(
                                'assets/create-home-background.png'),
                          ),
                          Positioned(
                            right: 25,
                            top: 15,
                            child: Text(
                              'Create',
                              style: TextStyle(
                                  fontFamily: 'OverpassBold',
                                  color: Colors.white,
                                  fontSize: 24),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed('/connectMeeting');
                            },
                            child: Image.asset(
                                'assets/connect-home-background.png'),
                          ),
                          Positioned(
                            right: 25,
                            bottom: 15,
                            child: Text(
                              'Connect',
                              style: TextStyle(
                                  fontFamily: 'OverpassBold',
                                  color: Colors.white,
                                  fontSize: 24),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              /*Padding(
                padding: const EdgeInsets.only(
                    top: 5, bottom: 5, right: 25, left: 25),
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/crearSala_practicas');
                  }, child: Text('Practicas'),
                )
              )*/
            ],
          ),
        ),
      ),
    );
  }
}
