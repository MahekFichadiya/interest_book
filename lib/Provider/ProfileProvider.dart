import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider extends ChangeNotifier {
  String _name = '';
  String _email = '';
  String _mobileNo = '';
  String _userId = '';

  String get name => _name;
  String get email => _email;
  String get mobileNo => _mobileNo;
  String get userId => _userId;

  Future<void> loadProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('name') ?? '';
    _email = prefs.getString('email') ?? '';
    _mobileNo = prefs.getString('mobileNo') ?? '';
    _userId = prefs.getString('userId') ?? '';
    notifyListeners();
  }

  Future<void> updateProfile(String name, String mobileNo, String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    await prefs.setString('mobileNo', mobileNo);
    await prefs.setString('email', email);
    _name = name;
    _mobileNo = mobileNo;
    _email = email;
    notifyListeners();
  }
}