import 'dart:async';

import 'package:flutter/material.dart';
import 'package:near_voice/model/colors.dart';
import 'package:near_voice/view/home.dart';

class InfoPopUpTwo extends StatefulWidget {
  // const InfoPopUp({Key key}) : super(key: key);

  @override
  _InfoPopUpTwoState createState() => _InfoPopUpTwoState();
}

class _InfoPopUpTwoState extends State<InfoPopUpTwo> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=> Home()));
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          height: screenHeight,
          // color: Colors.amberAccent,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(right: 20),
                  // color: Colors.greenAccent,
                  height: screenHeight * 0.10,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.close_outlined,
                          color: ColorsNearVoice.primaryColor,
                          size: 40,
                        ),
                        onPressed: () {
                          // Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  height: screenHeight * 0.8,
                  // color: Colors.yellow,
                  child: Center(
                    child: Column(
                      children: [
                        Container(
                            height: (screenHeight * 0.8) / 2,
                            child: Image.asset('assets/wifi-info-background.png',
                                fit: BoxFit.cover)),
                        Container(
                          padding: EdgeInsets.all(14),
                          height: (screenHeight * 0.8) / 2,
                          alignment: Alignment.center,
                          // color: Colors.lightBlueAccent,
                          child: Text(
                            'Devices must be connected to the same WI-FI network to join a meeting',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: ColorsNearVoice.primaryColor
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
