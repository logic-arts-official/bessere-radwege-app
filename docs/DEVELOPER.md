# Developer Documentation

## Overview

This cycling data collection app is a Flutter-based mobile application for Android and iOS that collects cycling data to help improve bicycle infrastructure. The app records GPS location and sensor data during bike rides, anonymizes it, and uploads it to a server for analysis.

This project is based on the Bessere Radwege project by Matthias Krauss (© 2024), licensed under BSD-3 Clause. This fork is independently operated with its own backend infrastructure.

## Technology Stack

- **Framework**: Flutter (Dart SDK >=3.3.4 <4.0.0)
- **IDE**: Android Studio (recommended)
- **Build System**: Gradle (Android), Xcode (iOS)
- **State Management**: Provider package
- **Database**: SQLite (via sqflite package)
- **Map Rendering**: MapLibre GL
- **Key Dependencies**:
  - `provider` - State management
  - `sqflite` - Local database
  - `location` - GPS tracking
  - `maplibre_gl` - Map rendering
  - `http` - Network requests
  - `shared_preferences` - User settings
  - `pointycastle` & `rsa_encrypt` - Cryptography for data anonymization

## Project Structure

```
bessere-radwege-app/
├── android/              # Android-specific configuration
├── ios/                  # iOS-specific configuration
├── assets/               # Images, fonts, and map data
│   ├── images/          # App images and logos
│   ├── icon/            # App icon
│   ├── cologne.zip      # Offline map data (example)
│   ├── map-font.zip     # Map font resources
│   └── map-style.json   # Map styling configuration
├── lib/
│   ├── main.dart        # App entry point
│   ├── constants.dart   # App-wide constants
│   ├── enums.dart       # Enumerations (vehicle types, ride types, etc.)
│   ├── logger.dart      # Logging functionality
│   ├── server.dart      # Server configuration
│   ├── keys.dart.template  # Template for API keys (not in git)
│   ├── model/           # Data models
│   │   ├── user.dart           # User settings and preferences
│   │   ├── rides.dart          # Ride collection manager
│   │   ├── running_ride.dart   # Active ride tracking
│   │   ├── finished_ride.dart  # Completed ride with sync
│   │   ├── location.dart       # Location data point
│   │   ├── map_data.dart       # Map data management
│   │   └── annotation.dart     # Map annotations
│   ├── services/        # Background services
│   │   ├── sensor_service.dart # GPS and sensor data collection
│   │   └── sync_service.dart   # Server synchronization
│   └── view/            # UI screens and components
│       ├── main_screen.dart       # Main navigation screen
│       ├── first_boot_screen.dart # Initial consent screen
│       ├── record_screen.dart     # Active ride recording UI
│       ├── rides_pane.dart        # List of past rides
│       ├── no_rides_pane.dart     # Empty state UI
│       ├── settings_pane.dart     # User settings
│       └── info_pane.dart         # About/info screen
├── test/                # Unit and widget tests
├── pubspec.yaml         # Flutter dependencies
└── README.md            # Basic project info
```

## Getting Started

### Prerequisites

1. **Flutter SDK**: Install Flutter SDK 3.3.4 or later
   - Follow instructions at: https://docs.flutter.dev/get-started/install
2. **Android Studio** (for Android development)
   - Install from: https://developer.android.com/studio
   - Install Flutter and Dart plugins
3. **Xcode** (for iOS development, macOS only)
   - Install from Mac App Store
4. **Git**: For version control

### Initial Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/logic-arts-official/bessere-radwege-app.git
   cd bessere-radwege-app
   ```

2. **Install Flutter dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure API keys** (if needed):
   ```bash
   cp lib/keys.dart.template lib/keys.dart
   # Edit lib/keys.dart with your actual API keys
   ```

4. **Verify Flutter installation**:
   ```bash
   flutter doctor
   ```
   Fix any issues reported by `flutter doctor`.

### Building the App

#### Development Build

**Android**:
```bash
flutter run
# Or in Android Studio: Run > Run 'main.dart'
```

**iOS** (macOS only):
```bash
flutter run
# Or in Xcode: Product > Run
```

#### Release Build

**Android APK**:
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**Android App Bundle** (for Google Play):
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

**iOS** (requires Apple Developer account):
```bash
flutter build ios --release
# Then use Xcode to archive and upload
```

### Code Signing (Android)

For release builds, you need to configure code signing:

1. Create a keystore:
   ```bash
   keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
   ```

2. Create `android/key.properties`:
   ```properties
   storePassword=<your store password>
   keyPassword=<your key password>
   keyAlias=key
   storeFile=<path to key.jks>
   ```

3. **Important**: Add `android/key.properties` to `.gitignore` (already done).

## Development Workflow

### Running in Development Mode

1. Connect a physical device or start an emulator
2. Run: `flutter run` or use IDE run button
3. Hot reload: Press `r` in terminal or use IDE hot reload button
4. Hot restart: Press `R` or use IDE hot restart button

### Code Analysis and Linting

Run static analysis:
```bash
flutter analyze
```

The project uses `flutter_lints` package for linting rules, configured in `analysis_options.yaml`.

### Testing

Run all tests:
```bash
flutter test
```

Run specific test file:
```bash
flutter test test/widget_test.dart
```

Run tests with coverage:
```bash
flutter test --coverage
```

### Debugging

1. **Logs**: Use the built-in logger:
   ```dart
   import 'logger.dart';
   logInfo("Information message");
   logWarn("Warning message");
   logErr("Error message");
   ```

2. **Flutter DevTools**: Launch with:
   ```bash
   flutter pub global activate devtools
   flutter pub global run devtools
   ```

3. **Debug Console**: View logs in Android Studio's "Run" tab or terminal

## Architecture Overview

### State Management

The app uses the **Provider** pattern for state management:

- `User`: Manages user settings and preferences
- `Rides`: Manages the collection of rides (current and past)
- `FinishedRide`: Individual completed ride with change notifications

### Data Flow

1. **User starts ride** → `Rides.startRide()` → `SensorService.startRecording()`
2. **GPS updates** → `SensorService` adds `Location` to `RunningRide`
3. **User ends ride** → `Rides.finishCurrentRide()` → Creates `FinishedRide`
4. **Save to database** → `FinishedRide` persists to SQLite
5. **Sync to server** → `SyncService` uploads anonymized data

### Data Models

- **User**: Stores consent, default ride types, vehicle types
- **RunningRide**: Accumulates GPS points during active recording
- **FinishedRide**: Completed ride with metadata, stored in SQLite
- **Location**: Single GPS data point with timestamp and accuracy

### Services

- **SensorService**: Singleton that manages GPS location streaming
- **SyncService**: Singleton that handles background data upload with exponential backoff

### Database Schema

**rides table**:
- `uuid` (TEXT): Unique identifier
- `name` (TEXT): Display name
- `startDate`, `endDate` (REAL): Timestamps
- `dist`, `motionDist` (REAL): Distances in meters
- `duration`, `motionDuration` (REAL): Time in seconds
- `maxSpeed` (REAL): Maximum speed
- `privateKey`, `publicKey` (TEXT): RSA key pair for anonymization
- `rideType`, `vehicleType`, `mountType` (INTEGER): Enums
- `comment` (TEXT): User notes
- `syncAllowed`, `syncRevision`, `editRevision` (INTEGER): Sync state

**location table**:
- `rideId` (INTEGER): Foreign key to ride
- `timestamp` (REAL): Time of measurement
- `latitude`, `longitude` (REAL): Coordinates
- `accuracy` (REAL): GPS accuracy
- `altitude`, `altitudeAccuracy` (REAL): Elevation data
- `heading`, `headingAccuracy` (REAL): Direction
- `speed`, `speedAccuracy` (REAL): Velocity

## Configuration

### Constants (`lib/constants.dart`)

Key configurable values:
- `minMotionMperS` (1.4 m/s): Minimum speed to count as motion
- `locationDistanceFilterM` (2m): GPS filtering distance
- `minSyncDistanceM` (300m): Minimum distance to sync ride
- `minSyncDurationS` (30s): Minimum duration to sync ride
- `syncCutoffM` (100m): Distance threshold for sync logic
- `minSyncIntervalMS` (200ms): Minimum sync interval
- `maxSyncIntervalMS` (600000ms): Maximum sync interval (10 min)

### Server Configuration (`lib/server.dart`)

- Protocol: HTTPS
- Server configuration is in this file
- API endpoint: `/api/v1/rides`

**Note**: This fork uses independently operated backend infrastructure.

## Privacy and Security

The app implements strong privacy measures:

1. **User Consent**: Required on first launch
2. **Anonymization**: Each ride generates unique RSA key pair
3. **Pseudonymization**: Random seed for each ride
4. **Local Storage**: All data stored locally until user consent
5. **Encrypted Upload**: HTTPS for all server communication
6. **No Personal Data**: No names, accounts, or personal identifiers collected

## Common Development Tasks

### Adding a New Ride Property

1. Update `RunningRide` model
2. Update `FinishedRide` model and DB schema
3. Update database version in `finished_ride.dart`
4. Add migration logic in `_dbCreateTables`
5. Update UI to display/edit the property

### Adding a New Screen

1. Create file in `lib/view/`
2. Extend `StatelessWidget` or `StatefulWidget`
3. Add navigation logic in `main_screen.dart`
4. Update bottom navigation bar if needed

### Modifying Sync Logic

Edit `lib/services/sync_service.dart`:
- Update `_sync()` method for sync logic
- Adjust retry logic in `_syncActivityFailed()`
- Modify data preparation in `_prepareRideData()`

### Updating Map Style

1. Edit `assets/map-style.json`
2. Update map tiles if needed (see MapLibre GL documentation)
3. Test offline map functionality

## Troubleshooting

### Build Issues

**Problem**: Gradle build fails
- **Solution**: Update Android SDK, check `android/build.gradle` configuration
- Run: `cd android && ./gradlew clean`

**Problem**: iOS build fails
- **Solution**: Update pods: `cd ios && pod install`
- Clean build folder in Xcode: Product > Clean Build Folder

### Runtime Issues

**Problem**: Location permissions denied
- **Solution**: Check AndroidManifest.xml and Info.plist for permission declarations
- Enable location services in device settings

**Problem**: Database errors
- **Solution**: Clear app data or uninstall/reinstall app
- Check database version number

**Problem**: Sync failures
- **Solution**: Check server connectivity
- Verify API endpoint in `server.dart`
- Review sync service logs

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Make changes and test thoroughly
4. Run linter: `flutter analyze`
5. Commit with clear message: `git commit -m "Add feature X"`
6. Push to branch: `git push origin feature/my-feature`
7. Create pull request

## Code Style Guidelines

- Follow Dart style guide: https://dart.dev/guides/language/effective-dart/style
- Use `flutter format` to auto-format code
- Write meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused
- Use named parameters for clarity

## Resources

- **Flutter Documentation**: https://docs.flutter.dev/
- **Dart Language Tour**: https://dart.dev/guides/language/language-tour
- **Provider Package**: https://pub.dev/packages/provider
- **MapLibre GL**: https://maplibre.org/
- **Project Repository**: https://github.com/logic-arts-official/bessere-radwege-app

## License

This project is licensed under the BSD 3-Clause License - see LICENSE.txt for full license details.

Based on the Bessere Radwege project by Matthias Krauss (© 2024), licensed under BSD-3 Clause.
