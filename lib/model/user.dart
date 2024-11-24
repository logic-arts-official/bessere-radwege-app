import 'package:bessereradwege/logger.dart';
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
  int _defaultVehicleType = 0;
  int _defaultMountType = 0;
  int _defaultRideType = 0;
  String _rideComment = "";

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
      int? defaultVehicleType = _sharedPrefs.getInt('default_vehicle_type');
      if (defaultVehicleType != null) {
        _defaultVehicleType = defaultVehicleType;
      }
      int? defaultMountType = _sharedPrefs.getInt('default_mount_type');
      if (defaultMountType != null) {
        _defaultMountType = defaultMountType;
      }
      int? defaultRideType = _sharedPrefs.getInt('default_ride_type');
      if (defaultRideType != null) {
        _defaultRideType = defaultRideType;
      }
      String? rideComment = _sharedPrefs.getString('ride_comment');
      if (rideComment != null) {
        _rideComment = rideComment;
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

  int get defaultVehicleType => _defaultVehicleType;

  set defaultVehicleType(int val) {
    if (val != _defaultVehicleType) {
      _defaultVehicleType = val;
      if (_initialized) {
        _sharedPrefs.setInt('default_vehicle_type', val);
      }
      notifyListeners();
    }
  }

  int get defaultMountType => _defaultMountType;

  set defaultMountType(int val) {
    if (val != _defaultMountType) {
      _defaultMountType = val;
      if (_initialized) {
        _sharedPrefs.setInt('default_mount_type', val);
      }
      notifyListeners();
    }
  }

  int get defaultRideType => _defaultRideType;

  set defaultRideType(int val) {
    if (val != _defaultRideType) {
      _defaultRideType = val;
      if (_initialized) {
        _sharedPrefs.setInt('default_ride_type', val);
      }
      notifyListeners();
    }
  }

  String get rideComment => _rideComment;

  set rideComment(String val) {
    if (val != _rideComment) {
      _rideComment = val;
      if (_initialized) {
        _sharedPrefs.setString('ride_comment', val);
        logInfo("setting rideComment to $val");
      }
    }
  }

  void reset() {
    uploadConsent = false;
    firstStart = true;
    defaultRideType = 0;
    defaultMountType = 0;
    defaultVehicleType = 0;
    rideComment = "";
  }
}