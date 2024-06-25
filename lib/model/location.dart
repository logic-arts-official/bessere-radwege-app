import 'dart:math';

class Location {
  final DateTime _timestamp;
  final double _latitude;         //degrees
  final double _longitude;        //degrees
  final double _accuracy;         //lat / lon, meters
  final double _altitude;         //meters
  final double _altitudeAccuracy; //meters
  final double _heading;          //degrees
  final double _headingAccuracy;  //degrees
  final double _speed;            //m/s
  final double _speedAccuracy;    //m/s

  Location ({required DateTime timestamp,
              required double latitude,
              required double longitude,
              required double accuracy,
              required double altitude,
              required double altitudeAccuracy,
              required double heading,
              required double headingAccuracy,
              required double speed,
              required double speedAccuracy}) :
        _timestamp = timestamp,
        _latitude = latitude,
        _longitude = longitude,
        _accuracy = accuracy,
        _altitude = altitude,
        _altitudeAccuracy = altitudeAccuracy,
        _heading = heading,
        _headingAccuracy = headingAccuracy,
        _speed = speed,
        _speedAccuracy = speedAccuracy;

  DateTime get timestamp => _timestamp;
  double get latitude => _latitude;
  double get longitude => _longitude;
  double get accuracy => _accuracy;
  double get altitude => _altitude;
  double get altitudeAccuracy => _altitudeAccuracy;
  double get heading => _heading;
  double get headingAccuracy => _headingAccuracy;
  double get speed => _speed;
  double get speedAccuracy => _speedAccuracy;

  double distance(Location other) {
    /* This is a simplified pythagoras version. This is cheating a bit, as it
    takes the distance along a straight line and not around the corresponding
    great circle.
    The correct general solution can be found using the Haversine formula,
    but for small distances in this case, this alternative is easier and
    numerically more stable.
    */
    final lat1Rad = _latitude * pi / 180.0;
    final lat2Rad = other.latitude * pi / 180.0;
    final lon1Rad = _longitude * pi / 180.0;
    final lon2Rad = other.longitude * pi / 180.0;

    const earthRadius = 6371000.0;
    final x = (lon2Rad-lon1Rad) * cos((lat1Rad+lat2Rad)/2);
    final y = (lat2Rad-lat1Rad);
    final d = sqrt(x*x + y*y) * earthRadius;

    return d;
  }

}