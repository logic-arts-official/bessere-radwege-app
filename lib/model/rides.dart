import 'package:bessereradwege/model/running_ride.dart';
import 'package:bessereradwege/model/finished_ride.dart';
import 'package:bessereradwege/services/sensor_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:toastification/toastification.dart';

class Rides extends ChangeNotifier {

  static Rides? _sharedRides;

  factory Rides() {
    _sharedRides ??= Rides._internal();
    return _sharedRides!;
  }

  Rides._internal();


  RunningRide? _currentRide;
  final List<FinishedRide> _pastRides = [];
  late Database _database;

  RunningRide? get currentRide => _currentRide;
  List<FinishedRide> get pastRides => _pastRides;

  Future<void> initialize() async {
//    final dbPath = await getDatabasesPath();
    _database = await openDatabase('rides.db', version:DB_VERSION, onCreate: _dbCreateTables);
    await _dbLoadRides();
  }

  void startRide() {
    print("startride");
    if (_currentRide == null) {
      SensorService().checkPermissions().then((ok) {
        print("permissions ok: $ok");
        if (ok) {
          _currentRide = RunningRide();
          SensorService().startRecording(_currentRide!).then((ok) {
            if (ok) {
              notifyListeners();
              print("started ride");
            } else {
              _currentRide = null;
              _showPrivilegesMessage();
            }
          });
        }
      });
    }
  }

  Future<void> finishCurrentRide() async {
    print("ride: finishCurrentRide");
    if (_currentRide != null) {
      print("ride: have current ride");
      SensorService().stopRecording();
      RunningRide ride = _currentRide as RunningRide;
      ride.finish();
      _pastRides.add(FinishedRide.fromRunningRide(ride, _database));
      print("ride: added ride to past rides, now ${_pastRides.length}");
      _currentRide = null;
      notifyListeners();
    }
  }

  Future<void> _dbCreateTables(db, version) async {
    await db.execute('CREATE TABLE ride('
        'id INTEGER PRIMARY KEY AUTOINCREMENT,'
        'uuid TEXT,'
        'name TEXT,'
        'startDate REAL,'
        'endDate REAL,'
        'dist REAL,'
        'motionDist REAL,'
        'duration REAL,'
        'motionDuration REAL,'
        'maxSpeed REAL,'
        'privateKey TEXT,'
        'publicKey TEXT,'
        'rideType INTEGER,'
        'vehicleType INTEGER,'
        'mountType INTEGER,'
        'flags INTEGER,'
        'comment TEXT,'
        'pseudonymSeed INTEGER,'
        'syncAllowed INTEGER,'
        'editRevision INTEGER,'
        'syncRevision INTEGER'
        ')');
    await db.execute('CREATE TABLE location('
        'id INTEGER PRIMARY KEY AUTOINCREMENT,'
        'rideId INTEGER,'
        'timestamp REAL,'
        'latitude REAL,'
        'longitude REAL,'
        'accuracy REAL,'
        'altitude REAL,'
        'altitudeAccuracy REAL,'
        'heading REAL,'
        'headingAccuracy REAL,'
        'speed REAL,'
        'speedAccuracy REAL'
        ')');
  }

  Future<void> _dbLoadRides() async {
    final rides = await _database.query('ride', orderBy: 'startDate');
    print("DATABASE: Loading rides $rides");
    for (final rideMap in rides) {
      _pastRides.add(FinishedRide.fromDbEntry(_database, rideMap));
    }
    notifyListeners();
  }

  void _showPrivilegesMessage() {
    toastification.show(
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
      title: Text("Berechtigungen korrigieren"),
      description: Text(
          "Bitte Standortberechtigungen für diese App auf 'immer' stellen."),
      alignment: Alignment.topLeft,
      autoCloseDuration: const Duration(seconds: 5),
    );
  }
}
