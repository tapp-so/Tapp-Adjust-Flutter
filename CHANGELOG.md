# Changelog

## 1.0.1 – 2025-10-08

### Added

- **iOS implementation** (`ComTappSoAdjustPlugin.swift`) wired to `TappSDK`:
  - `initialize`, `getPlatformVersion`, `shouldProcess`, `generateUrl`
  - `handleEvent`, `handleTappEvent`
  - `fetchLinkData`, `fetchOriginLinkData`
  - Adjust helpers: `adjustEnable/Disable/IsEnabled/GdprForgetMe`, `adjustTrackAdRevenue`, `adjustTrackThirdPartySharing`,
    `getAdjustAttribution`, `adjustVerifyAppStorePurchase`, `adjustTrackAppStoreSubscription`,
    `adjustConvert`, `adjustRequestAppTrackingAuthorization`, `adjustAppTrackingAuthorizationStatus`,
    `adjustUpdateSkanConversionValue`
- **EventChannel** support on iOS & Android:
  - Emits `onDeferredLinkReceived` and `onDidFailResolvingURL` (plus test hook `onTestListener` on Android).

### Changed

- **Package rename**: Flutter package is now `com_tapp_so_adjust`.
- **Android identifiers**:
  - Package name → `com.tapp.so.adjust`
  - MethodChannel → `com.tapp.so.adjust/methods`
  - EventChannel → `com.tapp.so.adjust/events`
  - Plugin class → `ComTappSoAdjustPlugin`
- **Dart API**:
  - New entry file `lib/com_tapp_so_adjust.dart` (migrated from `tapp_sdk.dart`).
  - Platform interface now `ComTappSoAdjustPlatform` with full surface: `initialize`, `shouldProcess`, `generateUrl`,
    `handleEvent`, `handleTappEvent`, `fetchLinkData`, `fetchOriginLinkData`, `getConfig`, `getPlatformVersion`.
- **Android build**:
  - `minSdkVersion` **24** (required by native Tapp/Adjust AAR).
  - Java/Kotlin **17** (compile options + `kotlinOptions.jvmTarget=17`).
- **iOS build**:
  - Deployment target **iOS 14.0** (or higher if your `Tapp` pod requires).
  - Podspec updated with `s.platform = :ios, '14.0'` and `s.dependency 'Tapp', '~> 1.x'`.

### Fixed

- Registrant loading issues due to mismatched Android package/paths.
- Consistent argument validation & error codes (`BAD_ARGS`, `URL_ERROR`, etc.) across platforms.

### Migration notes (Breaking)

- **Package name change**
  - In your `pubspec.yaml`:
    ```yaml
    dependencies:
      com_tapp_so_adjust: ^1.0.1
    ```
- **Android**
  - Add **JitPack** in your app’s `settings.gradle`:
    ```gradle
    dependencyResolutionManagement {
      repositories {
        google()
        mavenCentral()
        maven { url "https://jitpack.io" }
      }
    }
    ```
  - Ensure `minSdkVersion 24`, `compileSdkVersion 34`, Java/Kotlin 17.
  - If you resolve native AARs directly, use:
    ```gradle
    implementation "com.github.tapp-so:Tapp-Adjust:1.0.1"
    // and, if needed:
    // implementation "com.adjust.sdk:adjust-android:4.38.0"
    ```
- **iOS**
  - Set `platform :ios, '14.0'` in your `Podfile`, then `pod install`.
  - If `Tapp` lives in a private Specs repo, add that `source` before the CDN in the Podfile.

---

## 1.0.0

- Initial public plugin scaffolding and example app.
