
import 'dart:async';

import 'package:bessereradwege/model/location.dart';
import 'package:bessereradwege/constants.dart';
import 'package:bessereradwege/model/running_ride.dart';
import 'package:bessereradwege/model/user.dart';
import 'package:bessereradwege/services/sync_service.dart';
import 'package:bessereradwege/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'dart:math';
import 'package:sqflite/sqflite.dart';
import 'package:rsa_encrypt/rsa_encrypt.dart';
import 'package:pointycastle/api.dart' as crypto;
import 'package:uuid/uuid.dart';
import 'dart:convert'; // for the utf8.encode method


const DB_VERSION = 1;

class FinishedRide extends ChangeNotifier {
  //ride properties
  late String _uuid;
  late String _name;
  late DateTime _startDate;
  late DateTime _endDate;
  late double _distM;
  late double _motionDistM;
  late double _durationS;
  late double _motionDurationS;
  late double _maxSpeedMS;
  late double _pseudonymSeed;
  late crypto.AsymmetricKeyPair<crypto.PublicKey, crypto.PrivateKey> _keyPair;
  late RideType _rideType;
  late MountType _mountType;
  late VehicleType _vehicleType;
  late int _flags;
  late String _comment;

  final List<Location> _locations = []; //empty means not loaded or no locations found. See if we need to save a ride without locations.

  //persistence
  late Database _db;
  int _dbId = -1; //Negative means no id assigned yet

  //sync state
  late bool _syncAllowed;  //user sync consent
  late int _editRevision;  //increase with metadata edit
  late int _syncRevision;  //version on server or 0 if no data is on server at all


  String get uuid => _uuid;
  String get name => _name;
  DateTime get startDate => _startDate;
  DateTime? get endDate => _endDate;
  double get totalDistanceM => _distM;
  double get gpsDurationS => _durationS;
  double get totalDurationS => (_endDate.difference(_startDate).inMilliseconds / 1000);
  double get averageSpeedKmh => (totalDurationS > 0)  ? (totalDistanceM / totalDurationS) * 3.6 : 0.0;
  Duration get recordingDuration => _endDate.difference(_startDate);
  bool get syncable => ((_distM > Constants.MIN_SYNC_DISTANCE_M) && (totalDurationS > Constants.MIN_SYNC_DURATION_S));
  bool get syncAllowed => _syncAllowed;
  int get editRevision => _editRevision;
  int get syncRevision => _syncRevision;
  set syncRevision(int rev) { _syncRevision = rev; _dbUpsertRide(updateData: false); }

  FinishedRide.fromRunningRide(RunningRide rr, Database db) {
    _db = db;
    _uuid = const Uuid().v4();
    _startDate = rr.startDate;
    if (rr.endDate is DateTime) {
      _endDate = rr.endDate!;
    } else {
      print("FinishedRide fromRunningRide: Not finished. Assuming now.");
      _endDate = DateTime.now();
    }
    _name = _findDefaultName(); //start and end date must be set
    _distM = rr.totalDistanceM;
    _motionDistM = rr.motionDistanceM;
    _durationS = rr.durationS;
    _motionDurationS = rr.motionDurationS;
    _maxSpeedMS = rr.maxSpeedMS;
    _pseudonymSeed = Random.secure().nextDouble();
    _rideType = RideTypeByValue(User().defaultRideType);
    _mountType = MountTypeByValue(User().defaultMountType);
    _vehicleType = VehicleTypeByValue(User().defaultVehicleType);
    _flags = 0;
    _comment = "";
    _syncAllowed = true;
    _editRevision = 1;
    _syncRevision = 0;

    _locations.addAll(rr.locations);
    print("building finished ride from running ride with ${_locations.length} locations");
    _genKeyPair().then((_) {  //gen key pair then persist
      _dbUpsertRide(updateData: true).then((_) {
        SyncService().addRide(this);
      });
    });
  }

  FinishedRide.fromDbEntry(Database db, Map<String, Object?> map) {
    _db = db;
    print("DATABASE: Reading ride $map");
    assert(map['uuid'] is String);
    _uuid = map['uuid'] as String;
    assert(map['name'] is String);
    _name = map['name'] as String;
    assert(map['startDate'] is double);
    _startDate = DateTime.fromMicrosecondsSinceEpoch((1000000.0 * (map['startDate'] as double)).round());
    assert(map['endDate'] is double);
    _endDate = DateTime.fromMicrosecondsSinceEpoch((1000000.0 * (map['endDate'] as double)).round());
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
    _rideType = RideTypeByValue((map['rideType'] as int));
    assert(map['vehicleType'] is int);
    _vehicleType = VehicleTypeByValue(map['vehicleType'] as int);
    assert(map['mountType'] is int);
    _mountType = MountTypeByValue(map['mountType'] as int);
    assert(map['flags'] is int);
    _flags = map['flags'] as int;
    assert(map['comment'] is String);
    _comment = map['comment'] as String;
    assert(map['pseudonymSeed'] is double);
    _pseudonymSeed = map['pseudonymSeed'] as double;
    assert(map['syncAllowed'] is int);
    _syncAllowed = (map['syncAllowed'] as int) > 0;
    assert(map['editRevision'] is int);
    _editRevision = map['editRevision'] as int;
    assert(map['syncRevision'] is int);
    _syncRevision = map['syncRevision'] as int;

    /* Later on, locations should be lazily loaded when needed, e.g. using
     requestLocations() / releaseLocations() pairs. Right now, we just load them
     and then add add to sync
     */
    _requestLocations(db).then((val) {
      print("Loaded locations - going to sync");
      SyncService().addRide(this);
    });
  }

  String sign(String s) { //TODO: check if this works
    final data = const Utf8Encoder().convert(s);
    final signer = crypto.Signer('SHA-256/RSA');
    signer.init(true, crypto.PrivateKeyParameter<RSAPrivateKey>(_keyPair.privateKey));
    final signature = signer.generateSignature(data) as RSASignature;
    final signatureB64 = base64Encode(signature.bytes);
    return signatureB64;
  }

  Future<bool> _requestLocations(Database db) async {
    final locs = await _db.query('location', where: 'rideId = ?',  whereArgs: [_dbId], orderBy: 'timestamp');
    for (final locMap in locs) {
      final l = Location (
        timestamp:DateTime.fromMicrosecondsSinceEpoch((1000000.0 * (locMap['timestamp'] as double)).round()),
        latitude:locMap['latitude'] as double,
        longitude:locMap['longitude'] as double,
        accuracy:locMap['accuracy'] as double,
        altitude:locMap['altitude'] as double,
        altitudeAccuracy:locMap['altitudeAccuracy'] as double,
        heading:locMap['heading'] as double,
        headingAccuracy:locMap['headingAccuracy'] as double,
        speed:locMap['speed'] as double,
        speedAccuracy:locMap['speedAccuracy'] as double);
      _locations.add(l);
    }
    return true; //TODO: Error handling
  }

  Future<void> _genKeyPair() async {
    final helper = RsaKeyHelper();
    _keyPair = await helper.computeRSAKeyPair(helper.getSecureRandom());
  }

  String _findDefaultName() {
    if (recordingDuration.inHours > 2) {
      return Constants.LONG_RIDE;
    }
    final midHour = (_endDate.hour + _startDate.hour) / 2;
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

  Future<void> _dbUpsertRide({bool updateData = true}) async {
    final map = {
      'uuid': _uuid,
      'name': _name,
      'startDate': _startDate.microsecondsSinceEpoch.toDouble() / 1000000,
      'endDate': _endDate.microsecondsSinceEpoch.toDouble() / 1000000,
      'dist': _distM,
      'motionDist': _motionDistM,
      'duration': _durationS,
      'motionDuration': _motionDurationS,
      'maxSpeed': _maxSpeedMS,
      'publicKey': RsaKeyHelper().encodePublicKeyToPemPKCS1(_keyPair.publicKey as RSAPublicKey),
      'privateKey': RsaKeyHelper().encodePrivateKeyToPemPKCS1(_keyPair.privateKey as RSAPrivateKey),
      'rideType': _rideType.value,
      'vehicleType': _vehicleType.value,
      'mountType': _mountType.value,
      'flags': _flags,
      'comment': _comment,
      'pseudonymSeed':_pseudonymSeed,
      'syncAllowed':_syncAllowed ? 1 : 0,
      'editRevision':_editRevision,
      'syncRevision':_syncRevision,
    };
    final haveId = _dbId >= 0;
    if (haveId) {
      map['id'] = _dbId;
    }
    int id = await _db.insert(
      'ride',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("upsert prev id $_dbId new id $id");
    if (!haveId) {
      _dbId = id;
    }
    if (updateData) {
      final batch = _db.batch();
      batch.delete('location', where: 'rideId = ?', whereArgs: [_dbId]);
      print("dbUpsert ${_locations.length} locations");
      for (final loc in _locations) {
        final map = loc.toMap();
        map['rideId'] = _dbId;
        batch.insert('location', map);
      }
      await batch.commit();
      print("DATABASE: Upserted ride");
    }
  }

  double _randomizeTimeDelta() => _pseudonymSeed * -Constants.SYNC_RANDOMIZE_S;

  Map<String, dynamic> toAnonymousJson({bool withLocations = true, bool withAnnotations = true}) {
    final timeDelta = _randomizeTimeDelta();
    Map<String, dynamic> map = {};
    map['uuid'] = _uuid;
    map['startDate'] = _startDate.microsecondsSinceEpoch.toDouble() / 1000000 + timeDelta;
    map['endDate'] = _endDate.microsecondsSinceEpoch.toDouble() / 1000000 + timeDelta;
    map['dist'] = _distM;
    map['motionDist'] = _motionDistM;
    map['duration'] = _durationS;
    map['motionDuration'] = _motionDurationS;
    map['maxSpeed'] = _maxSpeedMS;
    map['publicKey'] = RsaKeyHelper().encodePublicKeyToPemPKCS1(_keyPair.publicKey as RSAPublicKey);
    map['rideType'] = _rideType.value;
    map['vehicleType'] = _vehicleType.value;
    map['mountType'] = _mountType.value;
    map['flags'] = _flags;
    map['comment'] = _comment;
    if (withLocations) {
      List<Map<String, dynamic>> locs = [];
      if (_locations.isNotEmpty) {
        Location firstLocation = _locations.first;
        Location lastLocation = _locations.last;
        double anonymizeRadius = Constants.SYNC_CUTOFF_M;
        int firstIdx = 0;
        int lastIdx = _locations.length-1;
        while (firstIdx < _locations.length) {  //clip start and end
          if (_locations[firstIdx].distance(firstLocation) < anonymizeRadius) {
            firstIdx++;
          } else {
            break;
          }
        }
        while (lastIdx >= 0) {
          if (_locations[lastIdx].distance(lastLocation) < anonymizeRadius) {
            lastIdx--;
          } else {
            break;
          }
        }
        for (int idx = firstIdx; idx <= lastIdx; idx++) {
          //add anonymized locations
          locs.add(_locations[idx].toMap(timeDelta: timeDelta));
        }
      }
      map['locations'] = locs;
    }
    if (withAnnotations) {
      //TODO
    }
    return map;
  }


}

