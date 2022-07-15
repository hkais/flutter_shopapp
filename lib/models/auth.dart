import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_shop/models/http_exception.dart';
import 'dart:async';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;

  final _baseUrl = "https://identitytoolkit.googleapis.com/v1/accounts";
  final webAPiKey = "AIzaSyBRnl-9frbt3sudy82Jvnjs4ZMjt0PEC7Q";

  Timer? _authTimer = null;

  String? get token {
    if (_token != null &&
        _expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  bool get isAuth {
    return token != null;
  }

  String? get userId {
    return _userId;
  }

  Future<void> signUp(String email, String password) async {
    final url = "$_baseUrl:signUp?key=$webAPiKey";

    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));

      final result = json.decode(response.body);
      if (result['error'] != null) {
        throw HttpException(result['error']['message']);
      }
      // _userId = result['localId'];
      // _token = result['idToken'];

      // final secondToExpire = int.parse(result['expiresIn']);
      // _expiryDate = DateTime.now().add(Duration(seconds: secondToExpire));
      // notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logIn(String email, String password) async {
    final url = "$_baseUrl:signInWithPassword?key=$webAPiKey";
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));
      final result = json.decode(response.body);
      if (result['error'] != null) {
        throw HttpException(result['error']['message']);
      }
      _userId = result['localId'];
      _token = result['idToken'];

      final secondToExpire = int.parse(result['expiresIn']);
      _expiryDate = DateTime.now().add(Duration(seconds: secondToExpire));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('expiryDate', _expiryDate!.toIso8601String());
      await prefs.setString('userId', _userId!);

      _autoLogOut();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logOut() async {
    _token = null;
    _expiryDate = null;
    _userId = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('expiryDate');
    await prefs.remove('userId');

    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    notifyListeners();
  }

  void _autoLogOut() async {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final secondsToExpire = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer =
        Timer(Duration(seconds: secondsToExpire), () async => await logOut());
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) return false;

    var expiryDateStr = prefs.getString('expiryDate');
    if (expiryDateStr == null) return false;
    if (DateTime.parse(expiryDateStr).isBefore(DateTime.now())) return false;

    _token = prefs.getString('token');
    _userId = prefs.getString('userId');
    _expiryDate = DateTime.parse(expiryDateStr);
    _autoLogOut();
    return true;
  }
}
