import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class Ride extends ChangeNotifier {

  final String _uuid = const Uuid().v4();
  final DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  String get uuid => _uuid;

  DateTime get startDate => _startDate;
  DateTime? get endDate => _endDate;
  double get lengthM => 123.0;

  bool get running {
    return (_endDate == null);
  }

  Duration get duration {
    if (_endDate != null) {
      return _endDate!.difference(_startDate);
    } else {
      return DateTime.now().difference(_startDate);
    }
  }

  void finish() {
    if (_endDate == null) {
      _endDate = DateTime.now();
      notifyListeners();
    }
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
      _currentRide = Ride();
      notifyListeners();
      print("started ride");
    }
  }

  void finishCurrentRide() {
    if (_currentRide != null) {
      Ride ride = _currentRide as Ride;
      ride.finish();
      _pastRides.add(ride);
      _currentRide = null;
      notifyListeners();
    }

  }

}