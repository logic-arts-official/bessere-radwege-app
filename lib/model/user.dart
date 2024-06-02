import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User extends ChangeNotifier {

  static User? _sharedUser;

  factory User() {
    _sharedUser ??= User._internal();
    return _sharedUser!;
  }

  User._internal();

  late SharedPreferences _sharedPrefs;

  bool _firstStart = true;
  bool _uploadConsent = false;
  bool _initialized = false;

  Future<void> initialize() async {
    if (!_initialized) {
      _sharedPrefs = await SharedPreferences.getInstance();
      bool? first = _sharedPrefs.getBool('first_start');
      if (first != null) {
        firstStart = first;
      }
      bool? consent = _sharedPrefs.getBool('upload_consent');
      if (consent != null) {
        uploadConsent = consent;
      }
      _initialized = true;
    }
  }

  bool get uploadConsent => _uploadConsent;

  set uploadConsent(bool val) {
    if (val != _uploadConsent) {
      _uploadConsent = val;
      if (_initialized) {
        _sharedPrefs.setBool('upload_consent', val);
      }
      notifyListeners();
    }
  }

  bool get firstStart => _firstStart;

  set firstStart(bool val) {
    if (val != _firstStart) {
      _firstStart = val;
      if (_initialized) {
        _sharedPrefs.setBool('first_start', val);
      }
      notifyListeners();
    }
  }

  void reset() {
    uploadConsent = false;
    firstStart = true;
  }
}