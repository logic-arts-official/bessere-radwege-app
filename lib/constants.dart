class Constants {
  static const String unnamedRide = "Radfahrt";
  static const String morningRide = "Radfahrt morgens";
  static const String lateMorningRide = "Radfahrt vormittags";
  static const String noonRide = "Radfahrt mittags";
  static const String afternoonRide = "Radfahrt nachmittgs";
  static const String eveningRide = "Radfahrt abends";
  static const String nightRide = "Radfahrt nachts";
  static const String longRide = "Lange Radfahrt";
  static const String startRecording = "Losfahren";
  static const String endRecording = "Fahrt beenden";

  static const double minMotionMperS = 1.4;
  static const int locationDistanceFilterM = 2;

  static const double minSyncDistanceM = 300.0;
  static const double minSyncDurationS = 30.0;

  static const double syncCutoffM = 100.0;
  static const double syncRandomizeS = 600.0;
  static const int minSyncIntervalMS = 200; //minimum interval (200ms) for network activities
  static const int maxSyncIntervalMS = 600000; //maximum interval (10 min) after exponential backup
}
