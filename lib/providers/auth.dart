import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_zone/models/http_exception.dart';

import '../constants.dart';

class Auth with ChangeNotifier {
  String _token;
  String _userId;
  DateTime _expiry;
  Timer _authTimer;

  bool get isAuthenticated {
    return token != null;
  }

  String get token {
    if(_expiry != null && _expiry.isAfter(DateTime.now()) && _token != null && _token.isNotEmpty){
      return _token;
    }
    return null;
  }

  String get userID {
    return _userId;
  }

  Future<void> signUp(String email, String pass) async {
    return _authenticate(email, pass, 'signUp');
  }

  Future<void> logIn(String email, String pass) async {
    return _authenticate(email, pass, 'signInWithPassword');
  }

  Future<void> _authenticate(String email, String pass, final String urlSegemnt) async {
    final url = 'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegemnt?key=${Constants.API_KEY}';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': pass,
          'returnSecureToken': true,
        }),
      );
      final data = json.decode(response.body);
      if(data['error'] != null){
        throw HttpException(data['error']['message']);
      }
      _token = data['idToken'];
      _userId = data['localId'];
      _expiry = DateTime.now().add(Duration(seconds: int.parse(data['expiresIn'])));

      _autoLogout();
      notifyListeners();
      storeSharedPrefs();
    } catch (err) {
      print(err.toString());
      throw err;
    }
  }

  void storeSharedPrefs() async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('token', _token);
    prefs.setString('userId', _userId);
    prefs.setString('expiry', _expiry.toIso8601String());
  }

  Future<bool> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if(!prefs.containsKey('token'))
      return false;
    
    final expiryDate = DateTime.parse(prefs.getString('expiry'));
    if(expiryDate.isBefore(DateTime.now()))
      return false;

    _token = prefs.getString('token');
    _userId = prefs.getString('userId');
    _expiry = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async{
    _token = null;
    _userId = null;
    _expiry = null;
    if(_authTimer != null){
      _authTimer.cancel();
      _authTimer = null;
    }

    await SharedPreferences.getInstance()..clear();
    notifyListeners();
  }

  void _autoLogout(){
    if(_authTimer != null){
      _authTimer.cancel();
    }
    final t = _expiry.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: t), logout);
  }
}
