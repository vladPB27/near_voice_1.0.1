import 'package:flutter/cupertino.dart';

class ActionsWidget extends ChangeNotifier{

  String _text = 'Mic Off';
  bool _isMuted = true;
  bool _isImgMuted = true;
  bool _isRemoved = false;
  bool _isSilenced = false;

  get text{
    return _text;
  }
  get isMuted{
    return _isMuted;
  }
  get isImgMuted{
    return _isImgMuted;
  }

  get isRemoved{
    return _isRemoved;
  }

  get isSilenced{
    return _isSilenced;
  }

  set isMuted(bool muted){
    this._isMuted = muted;
    // notifyListeners();
  }
  set isImgMuted(bool imgMuted){
    this._isImgMuted = imgMuted;
    notifyListeners();
  }
  set text(String txt){
    this._text = txt;
    notifyListeners();
  }
  set isRemoved(bool removed){
    this._isRemoved = removed;
    notifyListeners();
  }
  set isSilenced(bool silenced){
    this._isSilenced = silenced;
    notifyListeners();
  }
}