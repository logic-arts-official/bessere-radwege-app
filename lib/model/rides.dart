import 'package:bessereradwege/model/ride.dart';
import 'package:bessereradwege/services/sensor_service.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class Rides extends ChangeNotifier {

  static Rides? _sharedRides;

  factory Rides() {
    _sharedRides ??= Rides._internal();
    return _sharedRides!;
  }

  Rides._internal();


  Ride? _currentRide;
  final List<Ride> _pastRides = [];
  late Database _database;

  Ride? get currentRide => _currentRide;
  List<Ride> get pastRides => _pastRides;

  Future<void> initialize() async {
//    final dbPath = await getDatabasesPath();
    _database = await openDatabase('rides.db', version:DB_VERSION, onCreate: _dbCreateTables);
    print("DATABASE ride initialize open database");
    await _dbLoadRides();
  }

  void startRide() {
    print("startride");
    if (_currentRide == null) {
      SensorService().checkPermissions().then((ok) {
        print("permissions ok: $ok");
        if (ok) {
          _currentRide = Ride.forRecording();
          SensorService().startRecording(_currentRide!);
          notifyListeners();
          print("started ride");
        }
      });
    }
  }

  Future<void> finishCurrentRide() async {
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
      print("DATABASE: trying to persist _database is $_database");
      await ride.dbUpsertRide(_database);
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
        'comment TEXT'
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
      _pastRides.add(Ride.fromDbEntry(_database, rideMap));
    }
    notifyListeners();
  }
}
