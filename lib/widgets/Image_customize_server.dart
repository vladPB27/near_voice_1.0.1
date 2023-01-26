import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:near_voice/model/colors.dart';
import 'package:near_voice/model/icons.dart';
import 'package:near_voice/model/providers/meeting.dart';
import 'package:near_voice/model/providers/user.dart';
import 'package:provider/provider.dart';

class ImageCustomizeServer extends StatefulWidget {
  const ImageCustomizeServer({Key key}) : super(key: key);

  @override
  _ImageCustomizeServerState createState() => _ImageCustomizeServerState();
}

class _ImageCustomizeServerState extends State<ImageCustomizeServer> {
  final oIcon = new IconClass();

  @override
  Widget build(BuildContext context) {
    final userInfo = Provider.of<User>(context, listen: false);
    final double radiusImg = MediaQuery.of(context).size.width * 0.25;

    File _imageReal;
    if (userInfo.imageReal != null) {
      setState(() {
        _imageReal = File(userInfo.imageReal.path);
      });
    }

    return Scaffold(
      body: Stack(children: [
        Container(
          color: Colors.white,
        ),
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            child: CircleAvatar(
              radius: radiusImg,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: radiusImg-1,
                backgroundColor: Colors.white,
                backgroundImage: userInfo.imageReal != null
                    ? Image.file(
                        _imageReal,
                        fit: BoxFit.contain,
                      ).image
                    : userInfo.icon != null
                        ? AssetImage(userInfo.icon)
                        : AssetImage('assets/create-view-image.png'),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: CircleAvatar(
                    backgroundColor: ColorsNearVoice.primaryColor,
                    radius: 22.0,
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                        // side: BorderSide(color: Colors.white),
                      ),
                      color: HexColor('#006059'),
                      child: Icon(
                        Icons.edit_outlined,
                        size: 15.0,
                        color: Colors.white,
                      ),
                      onPressed: () => _imagePickerDialog(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  String _image1 = "";
  File _image;
  String _icon;
  final picker = ImagePicker();

  Future getFromGallery() async {
    final userInfo = Provider.of<User>(context, listen: false);

    userInfo.imageReal = await picker.getImage(source: ImageSource.gallery);
    // setState(() {
    if (userInfo.imageReal != null) {
      _image1 = userInfo.imageReal.path;
      _image = File(userInfo.imageReal.path);
      print('img selected path: ${json.encode(_image1)}');
      final bytes = File(userInfo.imageReal.path).readAsBytesSync();
      String _img64 = base64Encode(bytes);
      userInfo.image = _img64;
    } else {
      print('No image selected.');
    }
    // });
  }

  Future _getFromCamera() async {
    final userInfo = Provider.of<User>(context, listen: false);

    userInfo.imageReal = await picker.getImage(source: ImageSource.camera);

    if (userInfo.imageReal != null) {
      _image = File(userInfo.imageReal.path);
      final bytes = File(userInfo.imageReal.path).readAsBytesSync();
      String _img64Cam = base64Encode(bytes);
      userInfo.image = _img64Cam;
    }
  }

  _imagePickerDialog() {
    final userInfo = Provider.of<User>(context, listen: false);
    final meeting = Provider.of<Meeting>(context, listen: false);
    final double heightDialog = MediaQuery.of(context).size.height * 0.6;

    showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black45,
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (BuildContext buildContext, Animation animation,
            Animation secondaryAnimation) {
          return Padding(
            padding: EdgeInsets.only(bottom: heightDialog),
            child: Container(
              padding: EdgeInsets.all(10),
              color: HexColor('#003333').withOpacity(0.7),
              child: Column(
                children: [
                  Expanded(
                    child: SafeArea(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Column(
                              children: [
                                GestureDetector(
                                  child: Container(
                                    height: 70,
                                    width: 90,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: ColorsNearVoice.primaryColor),
                                    child: Icon(
                                      Icons.image_outlined,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                  onTap: () {
                                    getFromGallery();
                                    Navigator.of(context).pop();
                                  },
                                ),
                                Text(
                                  'Gallery',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      decoration: TextDecoration.none),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Column(
                              children: [
                                GestureDetector(
                                  child: Container(
                                    height: 70,
                                    width: 90,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: ColorsNearVoice.primaryColor),
                                    child: Icon(
                                      Icons.camera_alt_outlined,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                  onTap: () {
                                    // _getFromCamera();
                                    // Navigator.of(context).pop();
                                  },
                                ),
                                Text(
                                  "Camera",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      decoration: TextDecoration.none),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 10.0, right: 10, bottom: 10, top: 10),
                      child: Swiper(
                        pagination: SwiperControl(color: Colors.white),
                        itemCount: oIcon.iconMeetingList.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                userInfo.icon = oIcon.iconMeetingList[index];
                                userInfo.imageReal = null;
                                userInfo.image = null;
                                meeting.image = oIcon.iconMeetingList[index];
                                Navigator.of(context).pop();
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  fit: BoxFit.contain,
                                  image: AssetImage(oIcon.iconMeetingList[index]),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
