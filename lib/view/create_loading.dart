import 'dart:async';

import 'package:flutter/material.dart';
import 'package:near_voice/model/colors.dart';
import 'package:near_voice/view/server/create_meeting.dart';
import 'package:near_voice/view/server/meet_created.dart';
import 'package:admob_flutter/admob_flutter.dart';

class CreateLoading extends StatefulWidget {
  // const CreateLoading({Key? key}) : super(key: key);

  @override
  _CreateLoadingState createState() => _CreateLoadingState();
}

class _CreateLoadingState extends State<CreateLoading> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=> MeetCreated()));
    });
  }
  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Container(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: screenHeight * 0.15,
                  ),
                  Container(
                    // color: Colors.orangeAccent,
                    height: screenHeight * 0.4,
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/create-loading.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    // color: Colors.greenAccent,
                    padding: EdgeInsets.only(right: 8,left: 8),
                    height: screenHeight * 0.2,
                    // alignment: Alignment.center,
                    // color: Colors.lightBlueAccent,
                    child: Text(
                      'We connect your voice',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: ColorsNearVoice.primaryColor
                      ),
                    ),
                  ),
                  AdmobBanner(
                      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
                      adSize: AdmobBannerSize.BANNER),
                ],
              ),
            ),
          ),
        ),
    );
  }
}
