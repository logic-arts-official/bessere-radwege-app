import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:bessereradwege/constants.dart';
import 'package:bessereradwege/server.dart';
import 'package:bessereradwege/model/finished_ride.dart';
import 'package:bessereradwege/keys.dart';
import 'package:http/http.dart' as http;

class SyncService {

  static final SyncService _service = SyncService._internal();

  final _rides = Queue<FinishedRide>();
  Timer? _timer;
  int _interval = Constants.MIN_SYNC_INTERVAL_MS;

  factory SyncService() {
    return _service;
  }

  SyncService._internal() {
  }

  void addRide(FinishedRide ride) {
    _rides.add(ride);
    print("SyncService addRide");
    _restartTimerIfNeeded();
  }

  void _restartTimerIfNeeded() {
    if ((_timer == null) && (_rides.isNotEmpty)) {
      print("SyncService restarting timer interval: $_interval");
      _timer = Timer(Duration(milliseconds: _interval), _sync);
    }
  }

  /** a network action succeeded. Clear exponential backoff */
  void _syncActivitySucceeded() {
    _interval = Constants.MIN_SYNC_INTERVAL_MS;
  }

  /** a network action failed. Do exponential backoff */
  void _syncActivityFailed() {
    _interval = ((_interval * 3) / 2) as int;
    if (_interval > Constants.MAX_SYNC_INTERVAL_MS) {
      _interval = Constants.MAX_SYNC_INTERVAL_MS;
    }
  }

  void _sync() async {
    _timer = null;
    print("SyncService syncing");
    if (_rides.isNotEmpty) {
      FinishedRide ride = _rides.first;
      bool shouldSync = ride.syncable && ride.syncAllowed;
      //note: needXYZ are mutually exclusive
      bool needCreate = shouldSync && (ride.syncRevision == 0);
      bool needUpdate = shouldSync && (ride.syncRevision > 0) && (ride.syncRevision < ride.editRevision);
      bool needDelete = (!shouldSync) && (ride.syncRevision > 0);
      int lastRevision = ride.editRevision;
      print("sync ride ${ride.uuid} syncable ${ride.syncable} allowed ${ride.syncAllowed} revision $lastRevision synced ${ride.syncRevision} distM ${ride.totalDistanceM} durS ${ride.totalDurationS}");
      if (needCreate) {
        bool ok = await _createRide(ride);
        if (ok) {
          ride.syncRevision = lastRevision;
          _rides.removeFirst();
          _syncActivitySucceeded();
        } else {
          _syncActivityFailed();
        }
        _restartTimerIfNeeded();
      } else if (needUpdate) {
        bool ok = await _updateRide(ride);
        if (ok) {
          ride.syncRevision = lastRevision;
          _rides.removeFirst();
          _syncActivitySucceeded();
        } else {
          _syncActivityFailed();
        }
        _restartTimerIfNeeded();
      } else if (needDelete) {
        bool ok = await _deleteRide(ride);
        if (ok) {
          ride.syncRevision = 0;
          _rides.removeFirst();
          _syncActivitySucceeded();
        } else {
          _syncActivityFailed();
        }
        _restartTimerIfNeeded();
      } else {
        print("need nothing");
        //there was nothing to do with this entry
        _rides.removeFirst();
        _syncActivitySucceeded(); //well...
        _restartTimerIfNeeded();
      }
    }
    _restartTimerIfNeeded();
  }

  Future<bool> _createRide(FinishedRide ride) async {
    print("create");
    final ridedata = ride.toAnonymousJson(withLocations: true, withAnnotations: true);
    final ridedataJson = jsonEncode(ridedata);
    final signature = ride.sign(ridedataJson);
    final request = {
      'apikey'    : Keys.API_KEY,
      'uuid'      : ridedata['uuid'],
      'data'      : ridedataJson,
      'signature' : signature
    };
    return await _apiRequest(request);
  }

  Future<bool> _updateRide(FinishedRide ride) async {
    print("update");
    final ridedata = ride.toAnonymousJson(withLocations: false, withAnnotations: true);
    final ridedataJson = jsonEncode(ridedata);
    final signature = ride.sign(ridedataJson);
    final request = {
      'apikey'    : Keys.API_KEY,
      'uuid'      : ridedata['uuid'],
      'data'      : ridedataJson,
      'signature' : signature
    };
    return await _apiRequest(request);
  }

  Future<bool> _deleteRide(FinishedRide ride) async {
    print("delete");
    final ridedata = ride.toAnonymousJson(withLocations: false, withAnnotations: true);
    ridedata['action'] = "DELETE";
    final ridedataJson = jsonEncode(ridedata);
    final signature = ride.sign(ridedataJson);
    final request = {
      'apikey'    : Keys.API_KEY,
      'uuid'      : ridedata['uuid'],
      'data'      : ridedataJson,
      'signature' : signature
    };
    return await _apiRequest(request);
  }

  Future<bool> _apiRequest(Map<String, dynamic> request) async {
    try {
      final url = Uri(
        scheme: Server.PROTOCOL,
        host: Server.NAME,
        port: Server.PORT,
        path: Server.API_PATH
      );
      final json = jsonEncode(request);
      print("request is $json");
      final response = await http.post(url, headers: {HttpHeaders.contentTypeHeader: "application/json"}, body: json);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return (response.statusCode == 200);
    } catch (e) {
      print("_apiRequest exception $e");
      return false;
    }
  }


  }