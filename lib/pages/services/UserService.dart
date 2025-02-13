import 'package:flutter/material.dart';

class UserService extends ChangeNotifier{
  late String _userID = "bilal@gmail.com";



  String getUserID(){
    return _userID;
  }

  void setUserID(String userID){
    _userID=userID;
  }


}