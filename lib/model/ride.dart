
import 'package:bessereradwege/services/sensor_service.dart';
import 'package:bessereradwege/model/location.dart';
import 'package:bessereradwege/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import 'package:sqflite/sqflite.dart';
import 'package:rsa_encrypt/rsa_encrypt.dart';
import 'package:pointycastle/api.dart' as crypto;

const DB_VERSION = 1;

enum RideType {
  Unknown,
  Commute,
  Recreational,
  Other,
}

enum MountType {
  Unknown,
  Jacket,
  Pants,
  Vehicle,
  Other,
}

enum VehicleType {
  Unknown,
  Powered,
  Unpowered,
  Other,
}

class Ride extends ChangeNotifier {
  late String _uuid;
  String _name = Constants.UNNAMED_RIDE;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  final List<Location> _locations = []; //empty means not loaded or no locations found. See if we need to save a ride without locations.
  bool _statsValid = false;
  double _distM = 0.0;
  double _motionDistM = 0.0;
  double _durationS = 0.0;
  double _motionDurationS = 0.0;
  double _maxSpeedMS = 0.0;
  double _pseudonymSeed = Random.secure().nextDouble();
  int _dbId = -1;
  RideType _rideType = RideType.Unknown;
  MountType _mountType = MountType.Unknown;
  VehicleType _vehicleType = VehicleType.Unknown;
  String _comment = "";
  late crypto.AsymmetricKeyPair<crypto.PublicKey, crypto.PrivateKey> _keyPair;

  Ride.forRecording() {
    _uuid = const Uuid().v4();
    _genKeyPair();
  }

  String get uuid => _uuid;
  String get name => _name;
  DateTime get startDate => _startDate;
  DateTime? get endDate => _endDate;

  bool get running {
    return (_endDate == null);
  }

  Future<void> _genKeyPair() async {
    final helper = RsaKeyHelper();
    _keyPair = await helper.computeRSAKeyPair(helper.getSecureRandom());
  }

  void addLocation(Location l) {
    _locations.add(l);
    _statsValid = false;
    notifyListeners();
  }

  void finish() {
    if (_endDate == null) {
      _endDate = DateTime.now();
      _name = _findName();
      _validateStats();
      notifyListeners();
    }
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
    return (_motionDurationS > 0)
        ? (_motionDistM / _motionDurationS) / 3.6
        : 0.0;
  }



  void _validateStats() {
    if (!_statsValid) {
      Location? lastLoc;
      var dist = 0.0;
      var motionDist = 0.0;
      var time = 0.0;
      var motionTime = 0.0;
      var maxMS = 0.0;
      for (Location loc in _locations) {
        if (lastLoc != null) {
          final s = loc.timestamp
                  .difference(lastLoc.timestamp)
                  .inMicroseconds
                  .toDouble() /
              1000000;
          final m = loc.distance(lastLoc);
          final mpers = (s > 0) ? m / s : 0;
          if (mpers >= Constants.MIN_MOTION_M_PER_S) {
            motionDist += m;
            motionTime += s;
          }
          if (s > 0) {
            if (m / s > maxMS) {
              maxMS = m / s;
            }
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
      _maxSpeedMS = maxMS;
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

  Future<void> dbUpsertRide(Database db, {bool updateData = true}) async {
    assert(!running, "Cannot persist ride because it is still running");

    _validateStats();
    final map = {
      'uuid': _uuid,
      'name': _name,
      'startDate': _startDate.microsecondsSinceEpoch.toDouble() / 1000000,
      'endDate': _endDate!.microsecondsSinceEpoch.toDouble() / 1000000,
      'dist': _distM,
      'motionDist': _motionDistM,
      'duration': _durationS,
      'motionDuration': _motionDurationS,
      'maxSpeed': _maxSpeedMS,
      'publicKey': RsaKeyHelper().encodePublicKeyToPemPKCS1(_keyPair.publicKey as RSAPublicKey),
      'privateKey': RsaKeyHelper().encodePrivateKeyToPemPKCS1(_keyPair.privateKey as RSAPrivateKey),
      'rideType': _rideType.index,
      'vehicleType': _vehicleType.index,
      'mountType': _mountType.index,
      'comment': _comment,
      'pseudonymSeed':_pseudonymSeed,

    };
    final haveId = _dbId >= 0;
    if (haveId) {
      map['id'] = _dbId;
    }
    int id = await db.insert(
      'ride',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("upsert prev id $_dbId new id $id");
    if (!haveId) {
      _dbId = id;
    }
    if (updateData) {
      final batch = db.batch();
      batch.delete('location', where: 'rideId = ?', whereArgs: [_dbId]);
      for (final loc in _locations) {
        final map = loc.toMap();
        map['rideId'] = _dbId;
        batch.insert('location', map);
      }
      await batch.commit();
      print("DATABASE: Upserted ride");
    }
  }

  Ride.fromDbEntry(Database db, Map<String, Object?> map) {
    print("DATABASE: Reading ride $map");
    assert(map['uuid'] is String);
    _uuid = map['uuid'] as String;
    assert(map['name'] is String);
    _name = map['name'] as String;
    assert(map['startDate'] is double);
    _startDate = DateTime.fromMicrosecondsSinceEpoch((1000000.0 * (map['startDate'] as double)).round());
    assert(map['endDate'] is double);
    _startDate = DateTime.fromMicrosecondsSinceEpoch((1000000.0 * (map['endDate'] as double)).round());
    assert(map['dist'] is double);
    _distM = map['dist'] as double;
    assert(map['motionDist'] is double);
    _motionDistM = map['motionDist'] as double;
    assert(map['duration'] is double);
    _durationS = map['duration'] as double;
    assert(map['motionDuration'] is double);
    _motionDurationS = map['motionDuration'] as double;
    assert(map['maxSpeed'] is double);
    _maxSpeedMS = map['maxSpeed'] as double;
    assert(map['id'] is int);
    _dbId = map['id'] as int;
    assert(map['publicKey'] is String);
    String pubPem = map['publicKey'] as String;
    RSAPublicKey pubKey = RsaKeyHelper().parsePublicKeyFromPem(pubPem);
    assert(map['privateKey'] is String);
    String privPem = map['privateKey'] as String;
    RSAPrivateKey privKey = RsaKeyHelper().parsePrivateKeyFromPem(privPem);
    _keyPair = crypto.AsymmetricKeyPair(pubKey, privKey);
    assert(map['rideType'] is int);
    _rideType = RideType.values[(map['rideType'] as int)];
    assert(map['vehicleType'] is int);
    _vehicleType = VehicleType.values[(map['vehicleType'] as int)];
    assert(map['mountType'] is int);
    _mountType = MountType.values[(map['mountType'] as int)];
    assert(map['comment'] is String);
    _comment = map['comment'] as String;
    assert(map['pseudonymSeed'] is double);
    _pseudonymSeed = map['pseudonymSeed'] as double;
    _statsValid = true;

    print("TODO: actual location data is not loaded. We should provide a lambda-based mechanism for lazily loading and unloading");
  }


}

