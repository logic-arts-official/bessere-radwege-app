# Bessere Radwege App

A Flutter-based mobile application for collecting and analyzing cycling data to improve bicycle infrastructure in Cologne, Germany.

[![License](https://img.shields.io/badge/license-BSD--3--Clause-blue.svg)](LICENSE.txt)
[![Flutter](https://img.shields.io/badge/Flutter-3.3.4+-02569B?logo=flutter)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-lightgrey)](https://github.com/logic-arts-official/bessere-radwege-app)

## Overview

The "Bessere Radwege" (Better Bike Paths) app automatically records GPS and sensor data during bike rides. The collected data is anonymized and analyzed to identify problem areas like rough surfaces, detours, and dangerous spots, helping to improve cycling infrastructure for everyone in Cologne.

**Key Features:**
- 📍 Automatic GPS tracking during rides
- 🔒 Strong privacy protection with data anonymization
- 📊 Ride statistics and history
- 🗺️ Offline map support for Cologne
- ☁️ Secure data upload to analysis server
- 🎯 Contribution to open data for urban planning

## Quick Links

### 📚 Documentation

- **[User Guide](docs/USER_GUIDE.md)** - Installation instructions and how to use the app
- **[Developer Documentation](docs/DEVELOPER.md)** - Setup, building, and development guide
- **[Architecture Overview](docs/ARCHITECTURE.md)** - Technical architecture and design patterns
- **[Project Backlog](docs/BACKLOG.md)** - Bugs, improvements, issues, and roadmap

### 🌐 External Links

- **Project Website**: [www.bessere-radwege.de](https://www.bessere-radwege.de)
- **Part of**: un:box Cologne initiative by the City of Cologne

## For End Users

👉 **[Read the User Guide](docs/USER_GUIDE.md)** for installation instructions and usage information.

### Quick Start
1. Download the APK from releases or project contact
2. Enable "Install from unknown sources" on your Android device
3. Install the app and grant location permissions
4. Accept the data consent agreement
5. Start riding - the app records automatically!

## For Developers

👉 **[Read the Developer Documentation](docs/DEVELOPER.md)** for complete setup and development instructions.

### Quick Start
```bash
# Clone repository
git clone https://github.com/logic-arts-official/bessere-radwege-app.git
cd bessere-radwege-app

# Install dependencies
flutter pub get

# Run on connected device/emulator
flutter run
```

### Technology Stack
- **Framework**: Flutter (Dart)
- **Database**: SQLite
- **Maps**: MapLibre GL
- **State Management**: Provider
- **Platforms**: Android, iOS

## Project Status

**Current Version**: 0.1.2  
**Status**: Beta - Active Development

See [BACKLOG.md](docs/BACKLOG.md) for planned features and known issues.

## Contributing

Contributions are welcome! Please:

1. Read the [Developer Documentation](docs/DEVELOPER.md)
2. Check the [Backlog](docs/BACKLOG.md) for open tasks
3. Fork the repository
4. Create a feature branch
5. Make your changes with tests
6. Submit a pull request

## Privacy & Security

This app prioritizes user privacy:
- ✅ No user accounts or personal data collected
- ✅ All ride data anonymized before upload
- ✅ Unique encryption key per ride
- ✅ User consent required
- ✅ Local-first data storage

See the [Architecture Overview](docs/ARCHITECTURE.md) for technical details.

## License

Copyright 2024 Matthias Krauss. All rights reserved.

This project is licensed under the BSD 3-Clause License - see the [LICENSE.txt](LICENSE.txt) file for details.

## Acknowledgments

This app is part of the "un:box Cologne" project, funded by the City of Cologne.

Special thanks to all contributors and the cycling community of Cologne! 🚴‍♀️🚴‍♂️
