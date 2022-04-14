import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:near_voice/model/colors.dart';
import 'package:near_voice/model/icons.dart';
import 'package:near_voice/model/providers/user.dart';
import 'package:provider/provider.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

class ImageCustomizeProfile extends StatefulWidget {
  const ImageCustomizeProfile({Key key}) : super(key: key);

  @override
  _ImageCustomizeProfileState createState() => _ImageCustomizeProfileState();
}

class _ImageCustomizeProfileState extends State<ImageCustomizeProfile> {
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
                radius: radiusImg - 1,
                backgroundColor: Colors.white,
                backgroundImage: userInfo.imageReal != null
                    ? Image.file(
                        _imageReal,
                        fit: BoxFit.cover,
                      ).image
                    : userInfo.icon != null
                        ? AssetImage(userInfo.icon)
                        : AssetImage('assets/png/profile-2.png'),
                // backgroundImage: _image != null
                //     ? Image.file(
                //         _image,
                //         fit: BoxFit.cover,
                //       ).image
                //     : _icon != null
                //         ? AssetImage(_icon)
                //         : AssetImage('assets/png/profile-2.png'),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: CircleAvatar(
                    backgroundColor: ColorsNearVoice.thirdColor,
                    radius: 22.0,
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                        // side: BorderSide(color: Colors.white),
                      ),
                      color: ColorsNearVoice.thirdColor,
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

  File _image;
  String _icon;
  final picker = ImagePicker();

  Future getFromGallery() async {
    final userInfo = Provider.of<User>(context, listen: false);

    userInfo.imageReal = await picker.getImage(source: ImageSource.gallery);
    // final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (userInfo.imageReal != null) {
        // userInfo.imageReal = pickedFile.path;

        _image = File(userInfo.imageReal.path);
        final bytes = File(userInfo.imageReal.path).readAsBytesSync();
        String _img64 = base64Encode(bytes);
        userInfo.image = _img64;
      } else {
        print('No image selected.');
      }
    });
    // setState(() {
    //   if (pickedFile != null) {
    //     _image = File(pickedFile.path);
    //     // userInfo.imageReal = File(pickedFile.path);
    //     final bytes = File(pickedFile.path).readAsBytesSync();
    //     String _img64 = base64Encode(bytes);
    //     userInfo.image = _img64;
    //   } else {
    //     print('No image selected.');
    //   }
    // });
  }

  Future _getFromCamera() async {
    final userInfo = Provider.of<User>(context, listen: false);
    userInfo.imageReal = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (userInfo.imageReal != null) {
        _image = File(userInfo.imageReal.path);
        final bytes = File(userInfo.imageReal.path).readAsBytesSync();
        String _img64Cam = base64Encode(bytes);
        userInfo.image = _img64Cam;
      }
    });
  }

  _imagePickerDialog() {
    final userInfo = Provider.of<User>(context, listen: false);

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
              // color: ColorsNearVoice.primaryColor.withOpacity(0.7),
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
                                    // getFromGallery();
                                    // Navigator.of(context).pop();
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
                          containerHeight: 3,
                          pagination: SwiperControl(color: Colors.white),
                          itemCount: oIcon.iconList.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  userInfo.icon = oIcon.iconList[index];
                                  userInfo.imageReal = null;
                                  Navigator.of(context).pop();
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    fit: BoxFit.contain,
                                    image: AssetImage(oIcon.iconList[index]),
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                    // child: CarouselSlider(
                    //   items: oIcon.iconList
                    //       .map(
                    //         (item) => Center(
                    //           child: GestureDetector(
                    //             onTap: () {
                    //               setState(() {
                    //                 _icon = item;
                    //                 _image = null;
                    //                 Navigator.of(context).pop();
                    //               });
                    //             },
                    //             child: Container(
                    //               height: 80,
                    //               width: 80,
                    //               decoration: BoxDecoration(
                    //                 shape: BoxShape.circle,
                    //                 image: DecorationImage(
                    //                   fit: BoxFit.fill,
                    //                   image: AssetImage(item),
                    //                 ),
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //       )
                    //       .toList(),
                    //   options: CarouselOptions(
                    //     autoPlay: true,),
                    // ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
