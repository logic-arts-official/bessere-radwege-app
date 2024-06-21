import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:async/async.dart';
import 'package:bessereradwege/model/ride.dart';

class SensorService {

  static final SensorService _service = SensorService._internal();

  factory SensorService() {
    return _service;
  }

  SensorService._internal() {
    print("SensorService internal");
  }

  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

  Future<bool> checkPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      print("geolocator services are not enabled");
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        print("geolocator permission denied");
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      print("geolocator permission denied permanently");
      return false;
    }

    print("geolocator enabled and permission granted");
    return true;
  }

  StreamSubscription<Position>? _positionStreamSubscription;

  bool startRecording(Ride ride) {
    if (_positionStreamSubscription != null) {
      print("could not start recording, already running!");
      return false;
    }
    final locationSettings = LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 2);
    final positionStream = Geolocator.getPositionStream(locationSettings: locationSettings);
    //message loop
    _positionStreamSubscription = positionStream.listen((Position pos) {
      ride.addPosition(pos);
    });
    return true;
  }

  void stopRecording() {
    if (_positionStreamSubscription != null) {
      _positionStreamSubscription!.cancel().then((_) {
        print("position stream stopped.");
        _positionStreamSubscription = null;
      });
    }
  }
}

