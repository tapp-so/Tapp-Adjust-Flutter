# com_tapp_so_adjust

`com_tapp_so_adjust` is a Flutter plugin for Android and iOS that exposes Tapp + Adjust through one Dart API. Use it to initialize the SDK, generate affiliate URLs, process incoming/deferred links, and track events from Flutter while keeping platform-specific Adjust helpers available when needed.

## Prerequisites

- Flutter `>=3.0.0`
- Dart `>=2.17.0 <4.0.0`
- Tapp credentials:
  - `authToken`
  - `tappToken`
- Environment selection via `EnvironmentType`:
  - `EnvironmentType.SANDBOX`
  - `EnvironmentType.PRODUCTION`
- Android app configuration:
  - `minSdk 24`
  - `compileSdk 34` (or higher)
  - Java/Kotlin target `1.8` (or higher)
- iOS app configuration:
  - deployment target `13.0` (or higher)

## Installation

### 1) Add dependency

```yaml
# pubspec.yaml
dependencies:
  com_tapp_so_adjust: ^1.1.0
```

```bash
flutter pub get
```

### 2) Android setup (required)

Add JitPack to Gradle repositories so native Tapp artifacts can be resolved.

```gradle
// android/settings.gradle
dependencyResolutionManagement {
  repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
  repositories {
    google()
    mavenCentral()
    maven { url 'https://jitpack.io' }
  }
}
```

Confirm your app module targets compatible SDK/runtime levels.

```gradle
// android/app/build.gradle
android {
  compileSdkVersion 34

  defaultConfig {
    minSdkVersion 24
  }

  compileOptions {
    sourceCompatibility JavaVersion.VERSION_1_8
    targetCompatibility JavaVersion.VERSION_1_8
  }

  kotlinOptions {
    jvmTarget = '1.8'
  }
}
```

### 3) iOS setup

Set the iOS deployment target to `13.0` or later.

```ruby
# ios/Podfile
platform :ios, '13.0'
```

Then install/update pods.

```bash
cd ios
pod install
```

## Deep Link Setup

To enable incoming link handling, complete both steps:
1. Configure your application in the Tapp dashboard.
2. Enable Universal Links / App Links in your native app project.

> Note: After your application is configured in the Tapp dashboard, Tapp manages the association files required for link verification, including `apple-app-site-association` for iOS and `assetlinks.json` for Android. You do not need to host these files yourself.

### 1. Configure your application in the Tapp dashboard

General fields:
- `Application Name`
- `Android App Identifier`
- `iOS Bundle Identifier`
- `Apple App Store ID`

When `Enable Android Deep Linking` is enabled:
- `Enable Android Deep Linking`
- `SHA-256 Certificate Fingerprint`
- `Android App Scheme`

When `Enable iOS Universal Linking` is enabled:
- `Enable iOS Universal Linking`
- `App ID Prefix`
- `iOS App Scheme`

These values must match the real app configuration:
- `Android App Identifier` -> Android application ID (package name), for example `com.example.app`
- `SHA-256 Certificate Fingerprint` -> signing certificate fingerprint used for the app build
- `Android App Scheme` -> scheme configured in Android manifest, if your flow uses custom URL schemes
- `iOS Bundle Identifier` -> bundle identifier configured in Xcode
- `Apple App Store ID` -> published App Store app ID, where applicable
- `App ID Prefix` -> Apple Team ID / App ID prefix used for associated domains
- `iOS App Scheme` -> URL Types scheme in Xcode, if your flow uses schemes

### 2. Enable iOS Universal Links

1. In Xcode, open your app target and enable the **Associated Domains** capability.
2. Add the Tapp-managed link domain:

```text
applinks:your-tapp-link-domain.com
```

3. Ensure `iOS Bundle Identifier` and `App ID Prefix` match what was configured in the Tapp dashboard.
4. If custom URL schemes are part of your integration, ensure `iOS App Scheme` matches your app's URL Types configuration.
5. For reliable Universal Link validation, test on a physical device.

After dashboard setup, Tapp serves the required `apple-app-site-association` file for the configured link domain.

### 3. Enable Android App Links

Add an intent filter to the receiving activity (typically your launcher activity) in `android/app/src/main/AndroidManifest.xml`:

```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />

    <data
        android:scheme="https"
        android:host="your-tapp-link-domain.com" />
</intent-filter>
```

If needed, restrict matching with attributes such as `android:pathPrefix`.

Ensure these values align with Tapp dashboard configuration:
- `Android App Identifier` matches your Android application ID (package name).
- `SHA-256 Certificate Fingerprint` matches the certificate used to sign your app.
- If custom URL schemes are used, `Android App Scheme` matches your manifest configuration.

After dashboard setup, Tapp serves the required Digital Asset Links file (`assetlinks.json`) for the configured link domain.

### 4. Use the SDK link APIs

This setup is required for:
- `shouldProcess(...)`
- `fetchLinkData(...)`
- `fetchOriginLinkData()`
- deferred/incoming link handling callbacks

### Integration Checklist

- [ ] Add the package and run `flutter pub get`.
- [ ] Configure Android repositories with JitPack.
- [ ] Confirm Android `minSdk 24` / `compileSdk 34` and Java/Kotlin `1.8+`.
- [ ] Confirm iOS deployment target `13.0+`.
- [ ] Configure deep-link settings in the Tapp dashboard and enable native link handling for iOS and Android.
- [ ] Call `start(...)` once before link/event operations.
- [ ] Run the smoke test from **Verify Integration**.

## Minimal Integration

Use this as the minimum working initialization flow.

```dart
import 'package:flutter/widgets.dart';
import 'package:com_tapp_so_adjust/com_tapp_so_adjust.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sdk = ComTappSoAdjust();
  await sdk.start(
    authToken: 'YOUR_AUTH_TOKEN',
    env: EnvironmentType.SANDBOX,
    tappToken: 'YOUR_TAPP_TOKEN',
  );

  runApp(const Placeholder());
}
```

## Verify Integration

After `start(...)`, run a short smoke test.

```dart
final version = await sdk.getPlatformVersion();
final shouldHandle = await sdk.shouldProcess('https://example.com');

print('Platform version: $version');
print('shouldProcess(example): $shouldHandle');
```

Expected results:
- `getPlatformVersion()` returns a non-empty string.
- `shouldProcess(...)` returns `true` or `false` (no exception).

## Recommended App Bootstrap Pattern

Use this pattern when you want production-friendly startup behavior instead of calling `start(...)` directly in `main()`.
It keeps SDK initialization in one place, attaches listeners once, supports optional cold-start link handling, and exposes `loading/ready/error` state.

```dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:com_tapp_so_adjust/com_tapp_so_adjust.dart';

enum TappBootstrapState { idle, loading, ready, error }

class TappBootstrapController {
  TappBootstrapController({ComTappSoAdjust? sdk})
      : _sdk = sdk ?? ComTappSoAdjust();

  final ComTappSoAdjust _sdk;
  final ValueNotifier<TappBootstrapState> state =
      ValueNotifier(TappBootstrapState.idle);

  Object? lastError;
  Future<void>? _inFlight;
  bool _started = false;
  StreamSubscription<DeferredDeepLinkData>? _deferredSub;
  StreamSubscription<FailResolveData>? _failSub;

  Future<void> initialize({String? initialLink}) {
    return _inFlight ??= _initializeInternal(initialLink: initialLink)
        .whenComplete(() => _inFlight = null);
  }

  Future<void> _initializeInternal({String? initialLink}) async {
    if (_started) {
      state.value = TappBootstrapState.ready;
      return;
    }

    state.value = TappBootstrapState.loading;
    try {
      await _sdk.start(
        authToken: 'YOUR_AUTH_TOKEN',
        env: EnvironmentType.PRODUCTION,
        tappToken: 'YOUR_TAPP_TOKEN',
      );

      _deferredSub ??= _sdk.onDeferredDeepLink.listen((event) {
        debugPrint('Deferred link: ${event.tappUrl}');
      });
      _failSub ??= _sdk.onFailResolvingUrl.listen((event) {
        debugPrint('Deferred-link resolve failed: ${event.url} -> ${event.error}');
      });

      // Optional cold-start handling. Provide initialLink from your app/router.
      if (initialLink != null && await _sdk.shouldProcess(initialLink)) {
        final data = await _sdk.fetchLinkData(initialLink);
        debugPrint('Cold-start link data: $data');
      }

      _started = true;
      state.value = TappBootstrapState.ready;
    } catch (e, st) {
      lastError = e;
      debugPrint('Tapp bootstrap failed: $e\n$st');
      state.value = TappBootstrapState.error;
      rethrow;
    }
  }

  Future<void> dispose() async {
    await _deferredSub?.cancel();
    await _failSub?.cancel();
    state.dispose();
  }
}
```

Minimal widget wiring for the bootstrap state:

```dart
ValueListenableBuilder<TappBootstrapState>(
  valueListenable: bootstrap.state,
  builder: (context, state, _) {
    switch (state) {
      case TappBootstrapState.loading:
      case TappBootstrapState.idle:
        return const Text('Starting SDK...');
      case TappBootstrapState.error:
        return Text('Startup failed: ${bootstrap.lastError}');
      case TappBootstrapState.ready:
        return const Placeholder(); // Replace with your app's root widget.
    }
  },
);
```

Customize this pattern in your app by:
- Logging/forwarding listener events to your analytics layer.
- Converting `lastError` into your own retry UX.
- Passing initial link values from your routing/deep-link setup.

## Common Flows

### Initialize SDK

```dart
await sdk.start(
  authToken: 'YOUR_AUTH_TOKEN',
  env: EnvironmentType.PRODUCTION,
  tappToken: 'YOUR_TAPP_TOKEN',
);
```

### Generate an affiliate URL

```dart
final url = await sdk.generateUrl(
  influencer: 'creator_123',
  adGroup: 'spring_campaign',
  creative: 'banner_A',
  data: {
    'utm_source': 'partner',
    'utm_medium': 'influencer',
  },
);

print('Generated URL: $url');
```

`data` must be `Map<String, String>`.

### Process incoming links

```dart
const incoming = 'https://example.com/path';

if (await sdk.shouldProcess(incoming)) {
  final resolved = await sdk.fetchLinkData(incoming);
  print('Resolved link data: $resolved');
}

final original = await sdk.fetchOriginLinkData();
print('Origin link data: $original');
```

### Track events

Standard Adjust event token:

```dart
await sdk.handleEvent('adjust_event_token');
```

Tapp event with metadata:

```dart
await sdk.handleTappEvent(
  eventAction: EventAction.custom,
  customValue: 'my_custom_event',
  metadata: {
    'value': 19.99,
    'currency': 'USD',
    'is_first_purchase': true,
  },
);
```

Metadata rules enforced in Dart:
- Supported value types: `String`, `num`, `bool`
- `double` values must be finite (`NaN`/`Infinity` are rejected)
- `null` values are ignored
- Nested maps/lists/objects are rejected with `ArgumentError`

### Listen for deferred-link callbacks

```dart
final deferredSub = sdk.onDeferredDeepLink.listen((event) {
  print('Deferred link: ${event.tappUrl}');
});

final failSub = sdk.onFailResolvingUrl.listen((event) {
  print('Resolve failed: ${event.url} -> ${event.error}');
});

// Cancel when no longer needed.
await deferredSub.cancel();
await failSub.cancel();
```

### Inspect SDK config

```dart
final config = await sdk.getConfig();
print('Config: $config');
```

On iOS this currently returns an error payload (`getConfig not supported on iOS`).

## Platform-Specific Notes

### Android-only methods

- `adjustEnable`
- `adjustDisable`
- `adjustIsEnabled`
- `adjustGdprForgetMe`
- `adjustGetAdid`
- `adjustGetGoogleAdId`
- `adjustGetAmazonAdId`
- `adjustGetSdkVersion`
- `adjustGetGooglePlayInstallReferrer`
- `adjustSetPushToken`
- `adjustSetReferrer`
- `adjustOnResume`
- `adjustOnPause`
- `adjustTrackAdRevenue`
- `adjustTrackThirdPartySharing`
- `adjustTrackMeasurementConsent`
- `adjustAddGlobalCallbackParameter`
- `adjustAddGlobalPartnerParameter`
- `adjustRemoveGlobalCallbackParameter`
- `adjustRemoveGlobalPartnerParameter`
- `adjustRemoveGlobalCallbackParameters`
- `adjustRemoveGlobalPartnerParameters`
- `adjustVerifyAndTrackPlayStorePurchase`
- `adjustTrackPlayStoreSubscription`

### iOS-only methods

- `adjustGetIdfa`
- `adjustVerifyAppStorePurchase`
- `adjustTrackAppStoreSubscription`
- `adjustConvert`
- `adjustRequestAppTrackingAuthorization`
- `adjustAppTrackingAuthorizationStatus`
- `adjustUpdateSkanConversionValue`

### Behavior differences

- `getConfig()`:
  - Android returns SDK config data.
  - iOS returns `{ "error": true, "message": "getConfig not supported on iOS" }`.
- `start(...)` does not accept an affiliate parameter in Dart; native initialization currently uses Adjust affiliate internally.
- Platform checks are implemented in Dart for many methods; call each API only on its supported platform.

## Troubleshooting

### Android build fails to resolve Tapp artifacts

Symptom:
- `Could not find com.github.tapp-so...`

Fix:
- Ensure JitPack is present in your Gradle repositories (recommended in `dependencyResolutionManagement`).

### iOS compile error: `Extra argument 'metadata' in call`

Fix:
- Update to the latest Tapp/Tapp-Adjust pods and reinstall dependencies:

```bash
cd ios
pod repo update
pod install
```

### `ArgumentError` when sending metadata

Cause:
- A metadata value is not one of `String`, `num`, `bool`, or is a non-finite `double`.

Fix:
- Send only supported primitive values.

### `MissingPluginException`

Fix:

```bash
flutter clean
flutter pub get
```

Then rebuild the app.

## License

MIT © Tapp
