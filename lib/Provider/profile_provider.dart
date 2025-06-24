import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:interest_book/Api/profile_money_api.dart';

class ProfileProvider extends ChangeNotifier {
  String _name = '';
  String _email = '';
  String _mobileNo = '';
  String _userId = '';
  double _youGave = 0.0;
  double _youGot = 0.0;
  bool _isLoadingMoneyInfo = false;
  String _moneyInfoError = '';

  String get name => _name;
  String get email => _email;
  String get mobileNo => _mobileNo;
  String get userId => _userId;
  double get youGave => _youGave;
  double get youGot => _youGot;
  bool get isLoadingMoneyInfo => _isLoadingMoneyInfo;
  String get moneyInfoError => _moneyInfoError;

  Future<void> loadProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('name') ?? '';
    _email = prefs.getString('email') ?? '';
    _mobileNo = prefs.getString('mobileNo') ?? '';
    _userId = prefs.getString('userId') ?? '';
    notifyListeners();

    // Automatically fetch money info after loading profile
    if (_userId.isNotEmpty) {
      await fetchMoneyInfo();
    }
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

  Future<void> fetchMoneyInfo() async {
    // If userId is empty, try to load profile first
    if (_userId.isEmpty) {
      await loadProfile();
      if (_userId.isEmpty) {
        _moneyInfoError = 'User ID not available';
        notifyListeners();
        return;
      }
    }

    _isLoadingMoneyInfo = true;
    _moneyInfoError = '';
    notifyListeners();

    try {
      final moneyInfo = await ProfileMoneyApi.getProfileMoneyInfo(_userId);
      _youGave = moneyInfo['you_gave'] ?? 0.0;
      _youGot = moneyInfo['you_got'] ?? 0.0;
      _moneyInfoError = '';
    } catch (e) {
      _moneyInfoError = e.toString();
      _youGave = 0.0;
      _youGot = 0.0;
    } finally {
      _isLoadingMoneyInfo = false;
      notifyListeners();
    }
  }
}