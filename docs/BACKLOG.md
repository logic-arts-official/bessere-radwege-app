# Project Backlog

This document tracks bugs, improvements, issues, and tasks for the Bessere Radwege app.

**Last Updated**: 2025-10-28  
**App Version**: 0.1.2

---

## 🐛 Bugs

### Critical

None identified currently.

### High Priority

**BUG-001: Database migration not implemented**
- **Description**: When database schema changes, there's no migration logic
- **Impact**: Users will lose data on app updates that change the DB schema
- **Location**: `lib/model/rides.dart`, `lib/model/finished_ride.dart`
- **Solution**: Implement `onUpgrade` callback in `openDatabase()`
- **Effort**: Medium

**BUG-002: Keys template file required for build**
- **Description**: Missing `lib/keys.dart` from template breaks build
- **Impact**: New developers can't build without creating the file
- **Location**: Build process
- **Solution**: Add build-time check or generate empty keys file
- **Effort**: Low

### Medium Priority

**BUG-003: Hardcoded app version in Info pane**
- **Description**: Version string is hardcoded, doesn't match pubspec.yaml
- **Impact**: Inconsistent version reporting
- **Location**: `lib/view/info_pane.dart` line 37
- **Solution**: Read version from package info
- **Effort**: Low

**BUG-004: No error handling for failed sync**
- **Description**: Sync failures are logged but not shown to user
- **Impact**: Users don't know if data upload failed
- **Location**: `lib/services/sync_service.dart`
- **Solution**: Add UI notification for persistent failures
- **Effort**: Medium

**BUG-005: Location accuracy not validated**
- **Description**: Low-accuracy GPS points are stored without filtering
- **Impact**: Poor quality data may be uploaded
- **Location**: `lib/services/sensor_service.dart`
- **Solution**: Filter points with accuracy > threshold
- **Effort**: Low

### Low Priority

**BUG-006: No handling of permission revocation**
- **Description**: If user revokes permissions during ride, app doesn't handle it gracefully
- **Impact**: Ride may continue with no data being recorded
- **Location**: `lib/services/sensor_service.dart`
- **Solution**: Monitor permission status, show warning
- **Effort**: Medium

**BUG-007: Map style path might fail on some devices**
- **Description**: Asset loading paths may not work on all Android versions
- **Impact**: Map might not render correctly
- **Location**: `lib/model/map_data.dart`
- **Solution**: Test on various devices, add fallback
- **Effort**: Medium

**BUG-008: No cleanup of old logs**
- **Description**: Logger may accumulate large log files
- **Impact**: Storage space consumed over time
- **Location**: `lib/logger.dart`
- **Solution**: Implement log rotation or size limits
- **Effort**: Low

---

## 💡 Improvements

### Code Quality

**IMP-001: Add comprehensive unit tests**
- **Description**: Test coverage is minimal
- **Current**: Only basic widget test exists
- **Proposal**: Add tests for models, services, utilities
- **Priority**: High
- **Effort**: High

**IMP-002: Implement integration tests**
- **Description**: No end-to-end tests for key workflows
- **Proposal**: Test ride recording, sync, database operations
- **Priority**: High
- **Effort**: High

**IMP-003: Add code documentation**
- **Description**: Many functions lack documentation comments
- **Proposal**: Add dartdoc comments to all public APIs
- **Priority**: Medium
- **Effort**: Medium

**IMP-004: Improve error handling**
- **Description**: Many functions don't handle errors gracefully
- **Proposal**: Add try-catch blocks, user-friendly error messages
- **Priority**: High
- **Effort**: Medium

**IMP-005: Refactor database code**
- **Description**: Database operations mixed with business logic
- **Proposal**: Create separate Repository classes
- **Priority**: Medium
- **Effort**: High

**IMP-006: Extract constants to configuration**
- **Description**: Magic numbers throughout codebase
- **Proposal**: Move all constants to `constants.dart`
- **Priority**: Low
- **Effort**: Low

**IMP-007: Implement logging levels**
- **Description**: Logger doesn't support different log levels consistently
- **Proposal**: Add DEBUG, INFO, WARN, ERROR levels
- **Priority**: Low
- **Effort**: Low

**IMP-008: Add TypeScript-style null safety checks**
- **Description**: Some nullable types not properly handled
- **Proposal**: Audit all nullable types, add proper null checks
- **Priority**: Medium
- **Effort**: Medium

### Features

**IMP-009: Offline map for multiple cities**
- **Description**: Currently only Cologne map is included
- **Proposal**: Allow downloading maps for other cities
- **Priority**: Medium
- **Effort**: High

**IMP-010: Export ride data**
- **Description**: Users can't export their data (GPX, KML, CSV)
- **Proposal**: Add export functionality to ride details
- **Priority**: Medium
- **Effort**: Medium

**IMP-011: Statistics dashboard**
- **Description**: No overview of all-time statistics
- **Proposal**: Add screen with total distance, rides, achievements
- **Priority**: Low
- **Effort**: Medium

**IMP-012: Route planning**
- **Description**: App only records, doesn't help plan routes
- **Proposal**: Add route planning based on collected data
- **Priority**: Low
- **Effort**: High

**IMP-013: Social features**
- **Description**: No sharing or community features
- **Proposal**: Allow sharing rides (anonymized), leaderboards
- **Priority**: Low
- **Effort**: High

**IMP-014: Dark mode support**
- **Description**: Only light theme available
- **Proposal**: Add dark theme option
- **Priority**: Low
- **Effort**: Medium

**IMP-015: Multi-language support**
- **Description**: UI is only in German
- **Proposal**: Add English, potentially other languages
- **Priority**: Medium
- **Effort**: High

**IMP-016: Ride annotations**
- **Description**: Can't mark specific points during ride (e.g., potholes)
- **Proposal**: Add button to mark issues during recording
- **Priority**: High
- **Effort**: Medium

**IMP-017: Auto-pause detection**
- **Description**: Stops at traffic lights are recorded as riding
- **Proposal**: Detect stationary periods, auto-pause/resume
- **Priority**: Medium
- **Effort**: Medium

**IMP-018: Battery saver mode**
- **Description**: GPS runs at full power always
- **Proposal**: Reduce GPS frequency when speed is stable
- **Priority**: Low
- **Effort**: Medium

### UI/UX

**IMP-019: Loading indicators**
- **Description**: Some operations have no loading feedback
- **Proposal**: Add spinners/progress bars for all async operations
- **Priority**: Medium
- **Effort**: Low

**IMP-020: Empty state improvements**
- **Description**: Empty states could be more engaging
- **Proposal**: Add illustrations, better copy
- **Priority**: Low
- **Effort**: Low

**IMP-021: Ride detail map enhancement**
- **Description**: Map in ride details is basic
- **Proposal**: Add route line, start/end markers, statistics overlay
- **Priority**: Medium
- **Effort**: Medium

**IMP-022: Onboarding tutorial**
- **Description**: First-time users get minimal guidance
- **Proposal**: Add interactive tutorial after consent
- **Priority**: Low
- **Effort**: Medium

**IMP-023: Better settings organization**
- **Description**: Settings are flat list
- **Proposal**: Group settings by category
- **Priority**: Low
- **Effort**: Low

**IMP-024: Accessibility improvements**
- **Description**: No consideration for screen readers, high contrast
- **Proposal**: Add semantic labels, test with TalkBack/VoiceOver
- **Priority**: Medium
- **Effort**: Medium

### Performance

**IMP-025: Lazy load ride locations**
- **Description**: All GPS points loaded into memory
- **Proposal**: Paginate or stream location data
- **Priority**: Medium
- **Effort**: Medium

**IMP-026: Optimize map rendering**
- **Description**: Map with many points may lag
- **Proposal**: Simplify routes, use clustering
- **Priority**: Low
- **Effort**: High

**IMP-027: Background sync optimization**
- **Description**: Sync happens at fixed intervals
- **Proposal**: Use WorkManager for intelligent scheduling
- **Priority**: Medium
- **Effort**: Medium

**IMP-028: Reduce app size**
- **Description**: App bundle is large due to map data
- **Proposal**: Make map download optional, reduce asset size
- **Priority**: Low
- **Effort**: Medium

### Project Structure

**IMP-029: Continuous Integration setup**
- **Description**: No CI/CD pipeline
- **Proposal**: Set up GitHub Actions for build, test, lint
- **Priority**: High
- **Effort**: Medium

**IMP-030: Automated releases**
- **Description**: Manual release process
- **Proposal**: Automate APK building and versioning
- **Priority**: Medium
- **Effort**: Medium

**IMP-031: Code quality tools**
- **Description**: Only basic linting enabled
- **Proposal**: Add dart_code_metrics, additional lint rules
- **Priority**: Medium
- **Effort**: Low

**IMP-032: Environment configuration**
- **Description**: Server URL hardcoded
- **Proposal**: Support dev/staging/prod environments
- **Priority**: Low
- **Effort**: Low

---

## ❗ Issues

### Infrastructure

**ISSUE-001: No staging environment**
- **Description**: Testing against production server
- **Impact**: Risk of corrupting production data during development
- **Solution**: Set up staging server or mock backend
- **Priority**: High

**ISSUE-002: API documentation missing**
- **Description**: Server API not documented
- **Impact**: Difficult to implement client correctly
- **Solution**: Document API endpoints, request/response formats
- **Priority**: High

**ISSUE-003: No monitoring/analytics**
- **Description**: No visibility into app usage, crashes
- **Impact**: Can't detect issues or understand usage patterns
- **Solution**: Add Firebase Analytics or similar
- **Priority**: Medium

### Security

**ISSUE-004: Key generation security**
- **Description**: RSA key generation may not be cryptographically secure
- **Impact**: Potential privacy risk
- **Solution**: Audit crypto libraries, use secure random
- **Priority**: High

**ISSUE-005: No certificate pinning**
- **Description**: HTTPS but no cert pinning
- **Impact**: Vulnerable to MITM attacks
- **Solution**: Implement certificate pinning for API calls
- **Priority**: Medium

**ISSUE-006: API keys in code**
- **Description**: keys.dart template suggests committing keys
- **Impact**: Potential security leak
- **Solution**: Use environment variables or secure storage
- **Priority**: High

### Compliance

**ISSUE-007: GDPR compliance review needed**
- **Description**: Data handling needs GDPR audit
- **Impact**: Legal compliance risk
- **Solution**: Conduct privacy impact assessment
- **Priority**: High

**ISSUE-008: Privacy policy missing**
- **Description**: No in-app privacy policy
- **Impact**: App store requirements, user trust
- **Solution**: Add privacy policy screen and link
- **Priority**: High

**ISSUE-009: Data retention policy undefined**
- **Description**: No clear policy on how long data is kept
- **Impact**: Compliance and user trust
- **Solution**: Define and implement retention policy
- **Priority**: Medium

### Documentation

**ISSUE-010: API client code not documented**
- **Description**: Sync service implementation unclear
- **Impact**: Hard to maintain or debug
- **Solution**: Document protocol, data format, error codes
- **Priority**: Medium

**ISSUE-011: Build instructions incomplete**
- **Description**: README is minimal
- **Impact**: Difficult for new contributors
- **Solution**: **RESOLVED** - Comprehensive docs now available
- **Priority**: Low

---

## 📋 Tasks

### Immediate (Sprint 1)

**TASK-001: Set up CI/CD pipeline**
- **Description**: GitHub Actions for automated testing and building
- **Dependencies**: None
- **Effort**: 3 days
- **Priority**: High

**TASK-002: Fix database migrations**
- **Description**: Implement proper schema versioning
- **Dependencies**: None
- **Effort**: 2 days
- **Priority**: High

**TASK-003: Add error notifications to UI**
- **Description**: Show sync errors to users
- **Dependencies**: None
- **Effort**: 1 day
- **Priority**: High

**TASK-004: Security audit**
- **Description**: Review crypto implementation, key management
- **Dependencies**: None
- **Effort**: 3 days
- **Priority**: High

**TASK-005: Add privacy policy screen**
- **Description**: Legal compliance requirement
- **Dependencies**: Legal review
- **Effort**: 1 day
- **Priority**: High

### Short-term (Sprint 2-3)

**TASK-006: Implement unit test suite**
- **Description**: Tests for all models and services
- **Dependencies**: TASK-001
- **Effort**: 5 days
- **Priority**: High

**TASK-007: Add ride annotation feature**
- **Description**: Mark issues during ride
- **Dependencies**: None
- **Effort**: 3 days
- **Priority**: High

**TASK-008: GPS accuracy filtering**
- **Description**: Reject low-quality GPS points
- **Dependencies**: None
- **Effort**: 1 day
- **Priority**: Medium

**TASK-009: Auto-pause detection**
- **Description**: Detect and handle stops
- **Dependencies**: None
- **Effort**: 2 days
- **Priority**: Medium

**TASK-010: Export functionality**
- **Description**: GPX/KML/CSV export
- **Dependencies**: None
- **Effort**: 3 days
- **Priority**: Medium

### Medium-term (Sprint 4-6)

**TASK-011: Multi-language support**
- **Description**: English translation minimum
- **Dependencies**: None
- **Effort**: 5 days
- **Priority**: Medium

**TASK-012: Statistics dashboard**
- **Description**: All-time stats screen
- **Dependencies**: None
- **Effort**: 3 days
- **Priority**: Low

**TASK-013: Dark mode**
- **Description**: Complete dark theme
- **Dependencies**: None
- **Effort**: 3 days
- **Priority**: Low

**TASK-014: Accessibility audit**
- **Description**: Screen reader support, contrast
- **Dependencies**: None
- **Effort**: 5 days
- **Priority**: Medium

**TASK-015: iOS version**
- **Description**: Build and test for iOS
- **Dependencies**: iOS developer account
- **Effort**: 10 days
- **Priority**: Medium

### Long-term (Future)

**TASK-016: Route planning feature**
- **Description**: Suggest routes based on data
- **Dependencies**: Server-side analytics
- **Effort**: 15 days
- **Priority**: Low

**TASK-017: Multi-city support**
- **Description**: Dynamic map downloads
- **Dependencies**: Server infrastructure
- **Effort**: 10 days
- **Priority**: Low

**TASK-018: Social features**
- **Description**: Sharing, leaderboards
- **Dependencies**: Backend changes
- **Effort**: 20 days
- **Priority**: Low

**TASK-019: ML-based quality detection**
- **Description**: On-device ML for road quality
- **Dependencies**: TensorFlow Lite integration
- **Effort**: 15 days
- **Priority**: Low

**TASK-020: Offline mode improvements**
- **Description**: Full offline functionality
- **Dependencies**: None
- **Effort**: 7 days
- **Priority**: Low

---

## 🎯 Prioritization Framework

### Priority Levels

**Critical**: Must fix immediately, blocks releases or causes data loss  
**High**: Important for next release, significant impact  
**Medium**: Should include in upcoming sprints  
**Low**: Nice to have, future consideration

### Impact vs Effort Matrix

```
High Impact, Low Effort:
- BUG-003: Version display fix
- BUG-005: GPS accuracy filtering
- IMP-006: Extract constants
- IMP-019: Loading indicators
- TASK-003: Error notifications
- TASK-008: GPS filtering

High Impact, High Effort:
- IMP-001: Unit tests
- IMP-015: Multi-language
- TASK-001: CI/CD setup
- TASK-006: Test suite
- ISSUE-007: GDPR compliance

Low Impact, Low Effort:
- IMP-007: Logging levels
- IMP-023: Settings organization
- IMP-030: Automated releases

Low Impact, High Effort:
- IMP-013: Social features
- IMP-026: Map optimization
- TASK-018: Social features
```

---

## 📊 Metrics & Goals

### Current State (v0.1.2)
- **Test Coverage**: <10%
- **Code Documentation**: ~20%
- **Known Critical Bugs**: 0
- **Known High Priority Bugs**: 2
- **Open Issues**: 11

### Target State (v1.0)
- **Test Coverage**: >80%
- **Code Documentation**: >90%
- **Known Critical Bugs**: 0
- **Known High Priority Bugs**: 0
- **All Critical Issues**: Resolved

### Key Milestones

**v0.2.0** - Stability & Testing
- All high-priority bugs fixed
- CI/CD operational
- 50% test coverage
- Privacy policy added

**v0.3.0** - User Experience
- Ride annotations
- Export functionality
- Auto-pause
- Better error handling

**v0.4.0** - Internationalization
- English support
- Dark mode
- Accessibility improvements

**v1.0.0** - Production Ready
- 80% test coverage
- iOS version
- Full documentation
- All critical issues resolved

---

## 🔄 Review Cadence

This backlog should be reviewed and updated:
- **Weekly**: New bugs and immediate tasks
- **Monthly**: Priorities and sprint planning
- **Quarterly**: Long-term roadmap

Last Review: 2025-10-28  
Next Review: 2025-11-04

---

## 📝 Notes

- This is a living document - priorities may shift based on user feedback
- Effort estimates are approximate (developer days)
- Some tasks depend on external factors (server changes, legal review)
- Community contributions are welcome - see DEVELOPER.md for guidelines

## Contributing to this Backlog

Found a bug or have an idea? 
1. Check if it's already listed
2. Create a GitHub issue with detailed description
3. Reference this backlog in your issue
4. Link improvements to specific backlog items in PRs
