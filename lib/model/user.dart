import 'package:flutter/foundation.dart';

class User extends ChangeNotifier {

  var _firstStart = true;
  var _uploadConsent = false;

  bool get uploadConsent => _uploadConsent;

  set uploadConsent(bool val) {
    if (val != _uploadConsent) {
      _uploadConsent = val;
      notifyListeners();
    }
  }

  bool get firstStart => _firstStart;

  set firstStart(bool val) {
    if (val != _firstStart) {
      _firstStart = val;
      notifyListeners();
    }
  }
}