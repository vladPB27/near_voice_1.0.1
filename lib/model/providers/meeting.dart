import 'package:flutter/cupertino.dart';

class Meeting extends ChangeNotifier{
  String aName;
  String aDescription;
  String aImage;
  List<String> aListConnected;

  Meeting({this.aName,this.aDescription});

  String get name{
    return aName;
  }

  String get description{
    return aDescription;
  }

  String get image{
    return aImage;
  }

  List<String> get listConnected{
    return aListConnected;
  }

  set name(String pName){
    this.aName = pName;
    notifyListeners();
  }

  set description(String pDescription){
    this.aDescription = pDescription;
    notifyListeners();
  }

  set image(String pImage){
    this.aImage = pImage;
    notifyListeners();
  }

  set listConnected(List<String> pListConnected){
    this.aListConnected = pListConnected;
    notifyListeners();
  }
}