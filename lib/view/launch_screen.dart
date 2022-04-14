import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:near_voice/model/colors.dart';
import 'package:near_voice/model/providers/user.dart';
import 'package:near_voice/view/home.dart';
import 'package:near_voice/view/login.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

String finalName;
String finalStatus;

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({Key key}) : super(key: key);

  @override
  _LaunchScreenState createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getValidationData().whenComplete(() async {
      Timer(Duration(seconds: 2), () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => finalName == null ? Login() : Home()));
      });
    });
  }

  Future getValidationData() async {
    final userInfo = Provider.of<User>(context, listen: false);

    final SharedPreferences shared = await SharedPreferences.getInstance();
    var obtainName = shared.getString('name');
    var obtainStatus = shared.getString('status');

    userInfo.name = obtainName;
    userInfo.status = obtainStatus;
    setState(() {
      finalName = obtainName;
      finalStatus = obtainStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ColorsNearVoice.primaryColor,
      body: Center(
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                    height: screenWidth / 3,
                    width: screenWidth / 3,
                    child: Image.asset("assets/icon/nearvoice-app-logo.png")),
                Text(
                  'nearvoice',
                  style: TextStyle(
                      color: ColorsNearVoice.fourthColor,
                      fontSize: 26,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
