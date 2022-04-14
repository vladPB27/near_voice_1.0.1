// import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class User extends ChangeNotifier{
  String aName = '';
  String aStatus = '';
  String aImage = '';
  PickedFile aImageReal;
  String aIcon = '';
  String aMicOn = '';

  User({this.aName,this.aStatus,this.aImage,this.aImageReal,this.aIcon,this.aMicOn});

  String get name {
    return aName;
  }

  String get status {
    return aStatus;
  }
  String get image {
    return aImage;
  }

  PickedFile get imageReal {
    return aImageReal;
  }

  String get icon {
    return aIcon;
  }

  String get micOn {
    return aMicOn;
  }

  set name(String pName){
    this.aName = pName;
    notifyListeners();
  }
  set status(String pStatus){
    this.aStatus = pStatus;
    notifyListeners();
  }
  set image(String pImage){
    this.aImage = pImage;
    notifyListeners();
  }

  set imageReal(PickedFile pImageReal){
    this.aImageReal = pImageReal;
    notifyListeners();
  }

  set icon(String pIcon){
    this.aIcon = pIcon;
    notifyListeners();
  }

  set micOn(String pMic){
    this.aMicOn = pMic;
    // notifyListeners();
  }
}
