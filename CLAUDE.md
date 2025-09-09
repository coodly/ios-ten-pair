# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Build and Development
- **Build iOS app**: `xcodebuild -workspace TenPair.xcworkspace -scheme iOS build`
- **Build Catalyst app**: `xcodebuild -workspace TenPair.xcworkspace -scheme Catalyst build`
- **Run tests**: `swift test --package-path TenPair/`
- **Install dependencies**: `pod install`
- **Generate localized strings**: `swiftgen` (uses swiftgen.yml config)

### Fastlane
- **Deploy to TestFlight**: `fastlane beta` (increments build number, commits, builds, and uploads)

## Architecture

### Project Structure
This is a multi-platform iOS game app with the following key components:

**Build System**: Uses Xcode workspace with CocoaPods for external dependencies and Swift Package Manager for internal modular architecture.

**Targets**:
- `iOS`: Mobile iOS app with ads integration
- `Catalyst`: Mac Catalyst version without ads

**Modular Architecture**: The app uses Swift Package Manager with a highly modular structure organized into feature-based packages:
- **Core Features**: `Play`, `Save`, `Config`, `RandomLines` - core game logic
- **UI Features**: `PlayFeature`, `MenuFeature`, `PlayPresentationFeature` - SwiftUI/UIKit presentation layers  
- **Platform Features**: `AppLaunchMobile`, `AppLaunchDesktop` - platform-specific launching
- **External Integrations**: `PurchaseClientLive` (RevenueCat), `MobileAdsClientLive` (Google Mobile Ads), `CloudMessagesClientLive`

**Key Patterns**:
- Uses Composable Architecture (TCA) for state management
- Dependency injection with Swift Dependencies framework
- Client/Live pattern for external service integrations
- Presentation/Feature separation for UI components

**Concurrency**: Configured for strict concurrency with Swift 6 features enabled and actor data race checks.

### Key Directories
- `TenPair/Sources/`: Swift Package Manager modules
- `iOS/`: iOS-specific app code and storyboards
- `Catalyst/`: Catalyst-specific app code
- `Shared/`: Shared code between platforms
- `fastlane/`: Deployment automation
- `scripts/`: Build and localization scripts

### Dependencies
- **External**: RevenueCat (purchases), Google Mobile Ads, SwiftLog, CloudFeedback
- **Point-Free**: Composable Architecture, Swift Dependencies, Concurrency Extras
- **Internal**: Highly modular with 20+ internal Swift packages

### Testing
Tests are located in `TenPair/Tests/` with separate test targets for core modules like `PlayTests` and `RandomLinesTests`.