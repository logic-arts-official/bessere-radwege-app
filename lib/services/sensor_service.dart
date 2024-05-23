import 'dart:async';
import 'dart:isolate';
import 'package:geolocator/geolocator.dart';


class SensorService {

  static final SensorService _service = SensorService._internal();

  final ReceivePort _receivePort = ReceivePort(); //worker to main
  final Completer<void> _workerReady = Completer.sync();
  late SendPort _sendPort; //main to worker

  factory SensorService() {
    print("worker ready: ${_service._workerReady.isCompleted}");

    return _service;
  }

  SensorService._internal() {
    print("SensorService internal");
    _receivePort.listen(_handleMessagesFromWorker);
    Isolate.spawn(_worker, _receivePort.sendPort);
  }

  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

  bool workerRunning = false;

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

  static void _worker(SendPort sendPort) {
    print("sensor worker starting");

    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    //message loop
    receivePort.listen((dynamic message) async {
      print("worker got ${message}");
    });
  }

  void _handleMessagesFromWorker (dynamic message) {
    if (message is SendPort) {
      _sendPort = message;
      _workerReady.complete();
    } else {
      print("Got message from worker: ${message}");
    }
  }


}