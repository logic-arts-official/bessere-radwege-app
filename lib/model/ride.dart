import 'package:bessereradwege/services/sensor_service.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

class Ride extends ChangeNotifier {

  final String _uuid = const Uuid().v4();
  final DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  String get uuid => _uuid;

  DateTime get startDate => _startDate;
  DateTime? get endDate => _endDate;
  List<Position> positions = [];

  bool get running {
    return (_endDate == null);
  }

  Duration get duration {
    if (_endDate != null) {
      return _endDate!.difference(_startDate);
    } else if (positions.isNotEmpty) {
      return positions.last.timestamp.difference(_startDate);
    } else {
      return DateTime.now().difference(_startDate);
    }
  }

  double get lengthM {
    Position? lastPos;
    var dist = 0.0;
    for (Position pos in positions) {
      if (lastPos != null) {
        dist += Geolocator.distanceBetween(pos.latitude, pos.longitude, lastPos.latitude, lastPos.longitude);
      }
      lastPos = pos;
    }
    return dist;
  }

  void finish() {
    if (_endDate == null) {
      _endDate = DateTime.now();
      notifyListeners();
    }
  }

  void addPosition(Position p) {
    positions.add(p);
    print("added position ${p}, now ${positions.length}");
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
        print("permissions ok: ${ok}");
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