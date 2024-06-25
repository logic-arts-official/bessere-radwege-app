import 'package:bessereradwege/services/sensor_service.dart';
import 'package:bessereradwege/model/location.dart';
import 'package:bessereradwege/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class Ride extends ChangeNotifier {

  final String _uuid = const Uuid().v4();
  String _name = Constants.UNNAMED_RIDE;
  final DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  List<Location> _locations = [];
  bool _statsValid = false;
  double _distM = 0.0;
  double _motionDistM = 0.0;
  double _durationS = 0.0;
  double _motionDurationS = 0.0;

  String get uuid => _uuid;
  String get name => _name;
  DateTime get startDate => _startDate;
  DateTime? get endDate => _endDate;

  bool get running {
    return (_endDate == null);
  }

  Duration get recordingDuration {
    if (_endDate != null) {
      return _endDate!.difference(_startDate);
    } else if (_locations.isNotEmpty) {
      return _locations.last.timestamp.difference(_startDate);
    } else {
      return DateTime.now().difference(_startDate);
    }
  }

  double get totalDistanceM {
    if (!_statsValid) {
      _validateStats();
    }
    return _distM;
  }

  double get averageSpeedKmh {
    if (!_statsValid) {
      _validateStats();
    }
    return (_motionDurationS > 0) ? (_motionDistM/_motionDurationS)/3.6 : 0.0;
  }

  void finish() {
    if (_endDate == null) {
      _endDate = DateTime.now();
      _name = _findName();
      _validateStats();
      notifyListeners();
    }
  }

  void addLocation(Location l) {
    _locations.add(l);
    _statsValid = false;
    notifyListeners();
  }

  void _validateStats() {
    if (!_statsValid) {
      Location? lastLoc;
      var dist = 0.0;
      var motionDist = 0.0;
      var time = 0.0;
      var motionTime = 0.0;
      for (Location loc in _locations) {
        if (lastLoc != null) {
          final s = loc.timestamp
              .difference(lastLoc.timestamp)
              .inMicroseconds
              .toDouble() / 1000000;
          final m = loc.distance(lastLoc);
          final mpers = (s > 0) ? m / s : 0;
          if (mpers >= Constants.MIN_MOTION_M_PER_S) {
            motionDist += m;
            motionTime += s;
          }
          dist += m;
          time += s;
        }
        lastLoc = loc;
      }
      _distM = dist;
      _motionDistM = motionDist;
      _durationS = time;
      _motionDurationS = motionTime;
      _statsValid = true;
    }
  }

  String _findName() {
    if (running) {
      return Constants.UNNAMED_RIDE;
    }
    if (_endDate!.difference(_startDate).inHours > 2) {
      return Constants.LONG_RIDE;
    }
    final midHour = (_endDate!.hour + _startDate.hour) / 2;
    if ((midHour >= 7) && (midHour <= 9)) {
      return Constants.MORNING_RIDE;
    } else if ((midHour >= 9) && (midHour <= 12)) {
      return Constants.LATE_MORNING_RIDE;
    } else if ((midHour >= 12) && (midHour <= 14)) {
      return Constants.NOON_RIDE;
    } else if ((midHour >= 14) && (midHour < 18)) {
      return Constants.AFTERNOON_RIDE;
    } else if ((midHour >= 18) && (midHour < 22)) {
      return Constants.EVENING_RIDE;
    }
    return Constants.NIGHT_RIDE;
  }


}

class Rides extends ChangeNotifier {
  Ride? _currentRide;
  final List<Ride> _pastRides = [];

  Ride? get currentRide => _currentRide;

  List<Ride> get pastRides => _pastRides;

  void startRide() {
    print("startride");
    if (_currentRide == null) {
      SensorService().checkPermissions().then((ok) {
        print("permissions ok: $ok");
        if (ok) {
          _currentRide = Ride();
          SensorService().startRecording(_currentRide!);
          notifyListeners();
          print("started ride");
        }
      });
    }
  }

  void finishCurrentRide() {
    print("ride: finishCurrentRide");
    if (_currentRide != null) {
      print("ride: have current ride");
      SensorService().stopRecording();
      Ride ride = _currentRide as Ride;
      ride.finish();
      _pastRides.add(ride);
      print("ride: added ride to past rides, now ${_pastRides.length}");
      _currentRide = null;
      notifyListeners();
    }
  }
}