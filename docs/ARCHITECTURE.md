# Architecture Overview

## System Overview

This cycling data collection app is a mobile application built with Flutter that collects and analyzes cycling data to improve bicycle infrastructure. The system consists of three main components:

1. **Mobile App** (Flutter/Dart) - Records rides and manages data
2. **Local Database** (SQLite) - Stores ride data persistently
3. **Backend Server** (External) - Receives anonymized ride data

```
┌─────────────────────────────────────────┐
│           Mobile App (Flutter)           │
│  ┌────────────┐  ┌──────────────────┐  │
│  │     UI     │  │  State Management │  │
│  │  (Views)   │◄─┤    (Provider)    │  │
│  └────────────┘  └──────────────────┘  │
│         ▲                 ▲              │
│         │                 │              │
│         ▼                 ▼              │
│  ┌────────────┐  ┌──────────────────┐  │
│  │  Services  │  │      Models      │  │
│  │ (GPS/Sync) │◄─┤   (Data Layer)   │  │
│  └────────────┘  └──────────────────┘  │
│         │                 │              │
└─────────┼─────────────────┼──────────────┘
          │                 │
          ▼                 ▼
    ┌─────────┐      ┌──────────────┐
    │  GPS    │      │    SQLite    │
    │ Sensor  │      │   Database   │
    └─────────┘      └──────────────┘
          │
          ▼
    ┌──────────────────────────────┐
    │  Backend Server (HTTPS)      │
    │  (Independently operated)    │
    └──────────────────────────────┘
```

## Architecture Pattern

The app follows a **layered architecture** with clear separation of concerns:

### 1. Presentation Layer (View)
- **Location**: `lib/view/`
- **Responsibility**: UI components and user interaction
- **Pattern**: Stateful and Stateless Widgets
- **Key Components**:
  - `MainScreen` - Root navigation container
  - `FirstBootScreen` - Initial consent flow
  - `RecordScreen` - Active ride recording interface
  - `RidesPane` - List of past rides
  - `SettingsPane` - User preferences
  - `InfoPane` - About/information

### 2. State Management Layer
- **Location**: Integrated with models via Provider
- **Pattern**: Provider (Reactive State Management)
- **Key Components**:
  - `User` (ChangeNotifier) - User settings and preferences
  - `Rides` (ChangeNotifier) - Collection of all rides
  - `FinishedRide` (ChangeNotifier) - Individual ride with sync state
- **Flow**:
  - Views subscribe to state changes
  - State changes trigger UI updates
  - Business logic updates state
  - State persists to database

### 3. Business Logic Layer (Model)
- **Location**: `lib/model/`
- **Responsibility**: Data structures and business rules
- **Key Components**:
  - `User` - User profile and consent management
  - `Rides` - Ride collection orchestration
  - `RunningRide` - Active ride accumulation
  - `FinishedRide` - Completed ride with metadata
  - `Location` - GPS data point
  - `MapData` - Offline map management
- **Patterns**:
  - Singleton pattern for global state (User, Rides)
  - Factory pattern for data model creation
  - Observer pattern via ChangeNotifier

### 4. Service Layer
- **Location**: `lib/services/`
- **Responsibility**: External integrations and background tasks
- **Key Components**:
  - `SensorService` (Singleton) - GPS location streaming
  - `SyncService` (Singleton) - Server synchronization
- **Patterns**:
  - Singleton for service instances
  - Stream-based data flow for GPS
  - Queue-based processing for sync

### 5. Data Persistence Layer
- **Location**: SQLite (via sqflite package)
- **Responsibility**: Local data storage
- **Schema**:
  - `ride` table - Ride metadata and statistics
  - `location` table - GPS points for each ride
- **Access**: Managed by `FinishedRide` model

## Component Details

### User Flow Architecture

```
App Launch
    │
    ├─→ First Time?
    │   ├─→ Yes → FirstBootScreen
    │   │           ├─→ Read Info
    │   │           ├─→ Grant Consent
    │   │           └─→ Continue → MainScreen
    │   │
    │   └─→ No → MainScreen
    │
MainScreen (Bottom Navigation)
    │
    ├─→ Rides Tab
    │   ├─→ No Rides? → NoRidesPane
    │   │                   └─→ "Start Ride" Button
    │   │
    │   └─→ Has Rides? → RidesPane
    │                       ├─→ List of Past Rides
    │                       └─→ "Start Ride" Button
    │
    ├─→ Settings Tab → SettingsPane
    │                   ├─→ Default Vehicle Type
    │                   ├─→ Default Ride Type
    │                   ├─→ Default Mount Type
    │                   └─→ Upload Consent Toggle
    │
    └─→ Info Tab → InfoPane
                    └─→ Project Information

Start Ride
    │
    ├─→ Check Permissions
    │   ├─→ Not Granted → Request Permissions
    │   └─→ Granted → Continue
    │
    ├─→ Create RunningRide
    │
    ├─→ Start GPS Recording → SensorService
    │
    └─→ Show RecordScreen
        ├─→ Display Live Stats
        │   ├─→ Current Speed
        │   ├─→ Distance
        │   ├─→ Duration
        │   └─→ Map with Route
        │
        └─→ "End Ride" Button
            ├─→ Stop GPS Recording
            ├─→ Create FinishedRide
            ├─→ Save to Database
            ├─→ Queue for Sync
            └─→ Return to MainScreen
```

### Data Flow Architecture

#### Recording Flow
```
User Starts Ride
    │
    ▼
Rides.startRide()
    │
    ├─→ Check Permissions (SensorService)
    ├─→ Create RunningRide
    └─→ Start GPS Stream (SensorService)
            │
            ▼
        GPS Updates (1/sec)
            │
            ▼
        Location Data
            │
            ├─→ Parse LocationData
            └─→ Create Location Object
                    │
                    ▼
                RunningRide.addLocation()
                    │
                    ├─→ Add to locations list
                    ├─→ Invalidate stats cache
                    └─→ notifyListeners()
                            │
                            ▼
                        UI Updates
                        (RecordScreen)
```

#### Finishing Flow
```
User Ends Ride
    │
    ▼
Rides.finishCurrentRide()
    │
    ├─→ Stop GPS Stream
    ├─→ RunningRide.finish()
    │       ├─→ Set end time
    │       └─→ Calculate final stats
    │
    ├─→ Create FinishedRide
    │       ├─→ Copy data from RunningRide
    │       ├─→ Generate UUID
    │       ├─→ Generate RSA key pair
    │       ├─→ Generate pseudonym seed
    │       └─→ Set metadata
    │
    ├─→ Add to pastRides list
    │
    ├─→ Save to Database
    │       ├─→ Insert ride record
    │       └─→ Insert location records
    │
    └─→ Queue for Sync (SyncService)
```

#### Sync Flow
```
FinishedRide Ready for Sync
    │
    ▼
SyncService.addRide()
    │
    ├─→ Check if eligible (distance/duration)
    ├─→ Check user consent
    └─→ Add to sync queue
            │
            ▼
        Timer Triggered
            │
            ▼
        SyncService._sync()
            │
            ├─→ Check connectivity
            ├─→ Prepare ride data
            │       ├─→ Serialize ride metadata
            │       ├─→ Anonymize locations
            │       ├─→ Apply encryption
            │       └─→ Create JSON payload
            │
            ├─→ HTTP POST to server
            │       │
            │       ├─→ Success
            │       │   ├─→ Update syncRevision
            │       │   ├─→ Reset retry interval
            │       │   └─→ Remove from queue
            │       │
            │       └─→ Failure
            │           ├─→ Keep in queue
            │           ├─→ Exponential backoff
            │           └─→ Retry later
            │
            └─→ Schedule next sync
```

### State Management Architecture

```
┌──────────────────────────────────────────┐
│         MultiProvider (Root)             │
│  ┌────────────┐    ┌─────────────────┐  │
│  │    User    │    │     Rides       │  │
│  │ (Provider) │    │   (Provider)    │  │
│  └────────────┘    └─────────────────┘  │
└──────────────────────────────────────────┘
         │                    │
         ▼                    ▼
    [SharedPreferences]   [SQLite DB]
         │                    │
         ▼                    ▼
  ┌──────────────┐   ┌──────────────────┐
  │ firstStart   │   │  currentRide     │
  │ uploadConsent│   │  pastRides[]     │
  │ defaults...  │   └──────────────────┘
  └──────────────┘            │
                              ├─→ RunningRide
                              │   (Transient)
                              │
                              └─→ FinishedRide[]
                                  (Persistent)
                                       │
                                       └─→ notifyListeners()
                                               │
                                               ▼
                                          UI Rebuild
```

## Design Patterns Used

### 1. Singleton Pattern
**Used for**: Global service instances
- `User` - Single user profile
- `Rides` - Global ride collection
- `SensorService` - GPS service
- `SyncService` - Sync manager
- `MapData` - Map resource loader

**Implementation**:
```dart
class MyService {
  static final MyService _instance = MyService._internal();
  factory MyService() => _instance;
  MyService._internal();
}
```

### 2. Factory Pattern
**Used for**: Object creation from different sources
- `FinishedRide.fromRunningRide()` - From active ride
- `FinishedRide.fromDbEntry()` - From database
- Enum conversion functions

### 3. Observer Pattern
**Used for**: State change notifications
- `ChangeNotifier` for reactive state
- `Provider` for dependency injection
- Stream-based GPS updates

### 4. Repository Pattern
**Used for**: Data access abstraction
- Models handle their own persistence
- Database operations encapsulated in models
- Clear separation between business logic and storage

### 5. Service Locator Pattern
**Used for**: Singleton service access
- Services accessed via factory constructors
- Global service instances
- No explicit dependency injection

## Data Models

### Core Models Hierarchy

```
ChangeNotifier (Flutter)
    │
    ├─→ User
    │   └─→ SharedPreferences
    │
    ├─→ Rides
    │   ├─→ RunningRide? (0..1)
    │   └─→ FinishedRide[] (0..*)
    │
    └─→ FinishedRide
        ├─→ Location[] (0..*)
        └─→ SQLite Database

Location (Plain Dart Object)
    ├─→ timestamp
    ├─→ latitude, longitude
    ├─→ accuracy
    ├─→ speed, heading
    └─→ altitude
```

### Model Responsibilities

**User**:
- Load/save preferences
- Manage consent state
- Store default settings
- Notify on changes

**Rides**:
- Manage ride lifecycle
- Coordinate services
- Load past rides from DB
- Provide ride collection interface

**RunningRide**:
- Accumulate GPS points
- Calculate live statistics
- Provide real-time updates
- Transition to FinishedRide

**FinishedRide**:
- Store complete ride data
- Persist to/from database
- Manage sync state
- Handle anonymization

**Location**:
- Store single GPS measurement
- Calculate distances
- Provide coordinate utilities

## Service Architecture

### SensorService

**Purpose**: Manage GPS location tracking

**Lifecycle**:
1. Singleton creation
2. Permission checking
3. GPS stream subscription
4. Location updates → RunningRide
5. Background mode management
6. Stream cleanup on stop

**Key Methods**:
- `checkPermissions()` - Ensure GPS access
- `startRecording(ride)` - Begin GPS stream
- `stopRecording()` - End GPS stream

### SyncService

**Purpose**: Upload ride data to server

**Architecture**:
- Queue-based processing
- Exponential backoff on failures
- Timer-driven sync attempts
- Retry logic for failures

**Sync Criteria**:
- User consent granted
- Ride meets minimum length (300m)
- Ride meets minimum duration (30s)
- Network connectivity available

**Key Methods**:
- `addRide(ride)` - Queue ride for upload
- `_sync()` - Process sync queue
- `_syncActivitySucceeded()` - Reset retry timer
- `_syncActivityFailed()` - Exponential backoff

## Database Schema

### Entity Relationship

```
┌─────────────────────┐
│       ride          │
│─────────────────────│
│ id (PK)             │◄────┐
│ uuid                │     │
│ name                │     │
│ startDate           │     │
│ endDate             │     │
│ dist                │     │
│ motionDist          │     │
│ duration            │     │
│ motionDuration      │     │
│ maxSpeed            │     │
│ privateKey          │     │
│ publicKey           │     │ 1
│ rideType            │     │
│ vehicleType         │     │
│ mountType           │     │
│ flags               │     │
│ comment             │     │
│ pseudonymSeed       │     │
│ syncAllowed         │     │
│ editRevision        │     │
│ syncRevision        │     │
└─────────────────────┘     │
                            │
                            │ N
┌─────────────────────┐     │
│      location       │     │
│─────────────────────│     │
│ id (PK)             │     │
│ rideId (FK)         │─────┘
│ timestamp           │
│ latitude            │
│ longitude           │
│ accuracy            │
│ altitude            │
│ altitudeAccuracy    │
│ heading             │
│ headingAccuracy     │
│ speed               │
│ speedAccuracy       │
└─────────────────────┘
```

### Data Types
- **INTEGER**: IDs, enums, flags, revisions
- **TEXT**: UUID, keys, names, comments
- **REAL**: Timestamps, coordinates, measurements

## Security Architecture

### Privacy Protection Layers

1. **No User Accounts**
   - No registration required
   - No personal identifiers
   - Anonymous from start

2. **Per-Ride Anonymization**
   - Unique UUID per ride
   - RSA key pair per ride
   - Random pseudonym seed
   - No linkage between rides

3. **Data Encryption**
   - HTTPS for all communication
   - RSA encryption for sensitive data
   - Keys never leave device

4. **Consent Management**
   - Explicit opt-in required
   - Can be revoked anytime
   - Per-ride sync control

5. **Local-First Storage**
   - All data stored locally
   - Upload only with consent
   - User controls deletion

### Cryptographic Implementation

```
Ride Anonymization Flow:
    │
    ├─→ Generate RSA Key Pair (2048-bit)
    │   ├─→ Private Key (stored locally)
    │   └─→ Public Key (sent to server)
    │
    ├─→ Generate Random Pseudonym Seed
    │
    ├─→ Create Unique UUID
    │
    └─→ Upload Package:
        ├─→ Encrypted location data
        ├─→ Public key only
        ├─→ Anonymous UUID
        └─→ No personal metadata
```

## Performance Considerations

### Battery Optimization
- GPS polling: 1 Hz (1 update/second)
- Distance filter: 2m minimum
- Background mode only when recording
- Efficient location processing

### Memory Management
- Lazy loading of location points
- Stats caching in RunningRide
- Stream-based GPS (no buffering)
- Singleton services (single instance)

### Database Optimization
- Indexed queries on UUID
- Batch inserts for locations
- Lazy loading of ride details
- Connection reuse

### Network Optimization
- Exponential backoff on failures
- Queue-based sync (no duplicates)
- Minimum ride size (300m/30s)
- Connection state checking

## Testing Architecture

### Test Categories

1. **Unit Tests**
   - Model logic
   - Utility functions
   - Data transformations

2. **Widget Tests**
   - UI component rendering
   - User interactions
   - State changes

3. **Integration Tests**
   - GPS tracking flow
   - Database operations
   - Sync processes

### Test Structure
```
test/
├── widget_test.dart     # Example widget test
└── (add more tests)     # Future test files
```

## Deployment Architecture

### Build Variants

**Debug Build**:
- Development signing
- Debugging enabled
- Hot reload supported

**Release Build**:
- Production signing
- Optimized code
- Minified resources

### Distribution Channels

1. **Direct APK**:
   - Manual distribution
   - No store approval needed
   - Immediate updates

2. **Google Play** (Future):
   - App Bundle format
   - Automated updates
   - Wider reach

3. **iOS App Store** (Future):
   - IPA distribution
   - Apple approval process
   - TestFlight for testing

## Future Architecture Enhancements

### Potential Improvements

1. **Offline Sync Queue Persistence**
   - Store queue in database
   - Survive app restarts
   - More reliable sync

2. **Background Sync Service**
   - Android WorkManager
   - iOS Background Fetch
   - Scheduled uploads

3. **Advanced Analytics**
   - On-device ML for quality detection
   - Pothole detection
   - Route optimization

4. **Multi-City Support**
   - Dynamic map downloads
   - City-specific configurations
   - Regional servers

5. **Enhanced Privacy**
   - Differential privacy
   - More anonymization options
   - Local-only mode

## Conclusion

This app architecture prioritizes:
- **Simplicity**: Clear layer separation
- **Privacy**: Multiple anonymization layers
- **Reliability**: Robust sync and error handling
- **Efficiency**: Battery and performance optimization
- **Maintainability**: Clean code structure
- **Extensibility**: Easy to add features

The Flutter framework provides cross-platform capabilities while the Provider pattern ensures clean, reactive state management throughout the application.

## Attribution

This architecture is based on the Bessere Radwege project by Matthias Krauss (© 2024), licensed under BSD-3 Clause. This fork is independently operated and maintained.
