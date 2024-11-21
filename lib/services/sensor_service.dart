import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:bessereradwege/model/running_ride.dart';
import 'package:bessereradwege/constants.dart';
import 'package:bessereradwege/model/location.dart';

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

  bool startRecording(RunningRide ride) {
    if (_positionStreamSubscription != null) {
      print("could not start recording, already running!");
      return false;
    }
    const locationSettings = LocationSettings(accuracy: LocationAccuracy.high,
        distanceFilter: Constants.LOCATION_DISTANCE_FILTER_M);
    final positionStream = Geolocator.getPositionStream(locationSettings: locationSettings);
    //message loop
    _positionStreamSubscription = positionStream.listen((Position pos) {
      final loc = Location(
        timestamp: pos.timestamp,
        latitude: pos.latitude,
        longitude: pos.longitude,
        accuracy: pos.accuracy,
        altitude: pos.altitude,
        altitudeAccuracy: pos.altitudeAccuracy,
        heading: pos.heading,
        headingAccuracy: pos.headingAccuracy,
        speed: pos.speed,
        speedAccuracy: pos.speedAccuracy);
      ride.addLocation(loc);
    });
    return true;
  }

  void stopRecording() {
    if (_positionStreamSubscription != null) {
      _positionStreamSubscription!.cancel().then((_) {
        _positionStreamSubscription = null;
      });
    }
  }
}

