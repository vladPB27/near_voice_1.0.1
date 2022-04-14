import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:after_layout/after_layout.dart';
import 'package:near_voice/model/colors.dart';
import 'package:near_voice/model/providers/user.dart';
import 'package:near_voice/view/home.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class Login extends StatefulWidget {
  const Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with AfterLayoutMixin {
  @override
  void afterFirstLayout(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  final formKey = new GlobalKey<FormState>();

  final nameController = TextEditingController();
  final statusController = TextEditingController();
  // bool _validate = false;
  // bool isButtonEnabled = false;
  var defaultText = TextStyle(color: Colors.black,fontSize: 13);
  var linkText = TextStyle(
      decoration:TextDecoration.underline,color: ColorsNearVoice.secondaryColor,fontSize: 13
  );

  @override
  void dispose() {
    nameController.dispose();
    statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userInfo = Provider.of<User>(context);

    return Scaffold(
      body: Form(
        key: formKey,
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/login.jpg'), fit: BoxFit.cover)),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 0, top: 0.0),
                    child: Text(
                      'nearvoice',
                      style: TextStyle(
                          color: HexColor('#074643'),
                          fontSize: 46,
                          fontFamily: 'OverpassBold'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 70),
                    child: Text(
                      'connect your voice',
                      style: TextStyle(
                          color: HexColor('#074643'),
                          fontSize: 22,
                          fontFamily: 'OverpassBold'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 60, left: 60, top: 8, bottom: 8),
                    child: TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 15,horizontal: 25),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30.0))),
                          hintText: 'Name'),
                      validator: (value) => value.trim().length == 0
                          ? 'Enter your name to log in'
                          : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 60, left: 60, top: 8, bottom: 8),
                    child: TextFormField(
                      controller: statusController,
                      validator: (value) =>
                          (value.trim().length == 0)
                              ? 'Enter your status to log in'
                              : null,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 15,horizontal: 25),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30.0))),
                          hintText: 'Status'),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        right: 70, left: 70, top: 10, bottom: 10),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(children: [
                        TextSpan(
                          style: defaultText,
                          text: 'By logging in I accept the ',

                        ),
                        TextSpan(
                            style: linkText,
                            text: 'privacy policy',
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                var url = "https://nearvoice.app/store/privacy-policy/";
                                if (await canLaunch(url)) {
                                  await launch(url);
                                } else {
                                  throw "Cannot load Url $url";
                                }
                              }),
                        TextSpan(style: defaultText, text: ', and the '),
                        TextSpan(
                            style: linkText,
                            text: 'terms and conditions',
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                var url = "https://nearvoice.app/store/terms-and-conditions/";
                                if (await canLaunch(url)) {
                                  await launch(url);
                                } else {
                                  throw "Cannot load Url $url";
                                }
                              })
                      ]),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    width: 120,
                    child: TextButton(
                        style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          backgroundColor:
                              MaterialStateProperty.all<Color>(HexColor('#074643')),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                        ),
                        child: Text('Log in',style: TextStyle(fontFamily: 'OverpassBold',fontSize: 18),),
                        onPressed: () {
                          final form = formKey.currentState;
                          if (form.validate()) {
                            form.save();
                            userInfo.name = nameController.text;
                            userInfo.status = statusController.text;

                            _setPreferences();

                            // Navigator.of(context).pushReplacementNamed('/home');
                            Navigator.of(context).pushReplacementNamed('/info_popup_two');
                          }
                        },
                      ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _setPreferences() async {
    final SharedPreferences shared = await SharedPreferences.getInstance();
    shared.setString('name', nameController.text);
    shared.setString('status', statusController.text);
  }
}


