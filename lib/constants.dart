class Constants {
  static const String UNNAMED_RIDE = "Radfahrt";
  static const String MORNING_RIDE = "Radfahrt morgens";
  static const String LATE_MORNING_RIDE = "Radfahrt vormittags";
  static const String NOON_RIDE = "Radfahrt mittags";
  static const String AFTERNOON_RIDE = "Radfahrt nachmittgs";
  static const String EVENING_RIDE = "Radfahrt abends";
  static const String NIGHT_RIDE = "Radfahrt nachts";
  static const String LONG_RIDE = "Lange Radfahrt";

  static const double MIN_MOTION_M_PER_S = 1.4;
  static const int LOCATION_DISTANCE_FILTER_M = 2;

  static const double MIN_SYNC_DISTANCE_M = 300.0;
  static const double MIN_SYNC_DURATION_S = 30.0;

  static const double SYNC_CUTOFF_M = 100.0;
  static const double SYNC_RANDOMIZE_S = 600.0;
  static const int MIN_SYNC_INTERVAL_MS = 1000; //minimum interval (1 s) for network activities
  static const int MAX_SYNC_INTERVAL_MS = 600000; //maximum interval (10 min) after exponential backup
}
