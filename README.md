# com_tapp_so_adjust

Flutter plugin that wraps the native **Tapp** SDK with **Adjust** integration.  
Features: deferred deep-link handling, affiliate URL generation, tapp/analytics events, and Adjust helpers.

> Android package: `com.tapp.so.adjust` • iOS class: `ComTappSoAdjustPlugin`

---

## ✨ Features

- Initialize Tapp (env, tokens, affiliate)
- Should-process checks for incoming links
- Generate affiliate URLs (influencer/adgroup/creative + payload)
- Deferred deep-link stream + failure events
- Tapp domain events & simple event tokens
- Adjust helpers (enable/disable, GDPR, ad revenue, attribution, SKAN, etc.)

---

## 📦 Install

```yaml
dependencies:
  com_tapp_so_adjust: ^1.0.1

⚙️ Platform setup
Android

1.Add JitPack (required to resolve the native Tapp/Adjust AAR):

android/settings.gradle
dependencyResolutionManagement {
  repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
  repositories {
    google()
    mavenCentral()
    maven { url "https://jitpack.io" } // ← required
  }
}

2.minSdk / compileSdk / Java 17:
Your app should be at least

android {
  compileSdkVersion 34
  defaultConfig { minSdkVersion 24 }   // required by native AAR
  compileOptions {
    sourceCompatibility JavaVersion.VERSION_17
    targetCompatibility JavaVersion.VERSION_17
  }
  kotlinOptions { jvmTarget = '17' }
}

iOS

1.Deployment target: set iOS 14.0+ (or higher if your Tapp pod requires):
ios/Podfile
platform :ios, '14.0'

2.Install pods:
cd ios
pod install

🚀 Quick start

import 'package:flutter/material.dart';
import 'package:com_tapp_so_adjust/com_tapp_so_adjust.dart';

final tapp = ComTappSoAdjust();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await tapp.start(
    authToken: 'YOUR_AUTH',
    env: EnvironmentType.production, // or EnvironmentType.sandbox
    tappToken: 'YOUR_TAPP',
    affiliate: AffiliateType.adjust,
  );

  // Optional: listen for deferred deep-links
  tapp.onDeferredDeepLink.listen((d) {
    debugPrint('Deferred link: ${d.tappUrl}');
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('com_tapp_so_adjust demo')),
        body: const Center(child: Text('Hello Tapp + Adjust')),
      ),
    );
  }
}

Generate an affiliate URL:
final url = await tapp.generateUrl(
  influencer: 'creator_123',
  adGroup: 'spring_campaign',
  creative: 'banner_A',
  data: {'utm_medium': 'influencer'},
);
print('Tapp URL: $url');

Should process a deep link?:
final ok = await tapp.shouldProcess('https://your.domain/whatever');

Handle events:
// Simple event (e.g., Adjust token)
await tapp.handleEvent('abc123');

// Tapp-domain event (enum or custom)
await tapp.handleTappEvent(eventAction: EventAction.purchase);
// or custom:
await tapp.handleTappEvent(
  eventAction: EventAction.custom,
  customValue: 'level_up',
);

Deferred link streams:
// When a deferred link arrives
tapp.onDeferredDeepLink.listen((payload) {
  // payload: DeferredDeepLinkData (tappUrl, attrTappUrl, influencer, isFirstSession, data)
});

// When resolving the URL fails
tapp.onFailResolvingUrl.listen((err) {
  // err: FailResolveData (url, error)
});

📊 Adjust helpers (subset)

These call through to native Adjust wrappers exposed by Tapp.:
// Android only
await tapp.adjustEnable();
await tapp.adjustDisable();
final enabled = await tapp.adjustIsEnabled();
await tapp.adjustGdprForgetMe();
await tapp.adjustTrackAdRevenue(AdjustTrackAdRevenueType(
  source: 'admob',
  revenue: 1.23,
  currency: 'USD',
));
await tapp.adjustTrackThirdPartySharing(true);
await tapp.adjustTrackMeasurementConsent(true);

// iOS only
final status = await tapp.adjustRequestAppTrackingAuthorization();
final current = await tapp.adjustAppTrackingAuthorizationStatus();
await tapp.adjustUpdateSkanConversionValue(UpdateSkanConversionValueType(
  value: 42,
  coarseValue: 'medium',
  lockWindow: 1,
));

🔎 Public API (Dart)
Core

start({authToken, env, tappToken, affiliate})

getPlatformVersion()

shouldProcess(String deepLink)

generateUrl({influencer, adGroup, creative, data})

handleEvent(String eventToken)

handleTappEvent({eventAction, customValue})

fetchLinkData(String deepLink)

fetchOriginLinkData()

getConfig()

Streams

onDeferredDeepLink → Stream<DeferredDeepLinkData>

onFailResolvingUrl → Stream<FailResolveData>

Adjust (platform-dependent)
See examples above.

All domain models are exported from package:com_tapp_so_adjust/com_tapp_so_adjust.dart (re-exports from src/models.dart).

🧯 Troubleshooting

Android:

Could not find com.github…
→ Add maven { url "https://jitpack.io" } to android/settings.gradle repositories.

minSdkVersion error
→ Set minSdkVersion 24 in your app build.gradle.

Java/Kotlin mismatch
→ Set Java 17 in compileOptions and kotlinOptions.jvmTarget = '17'.

iOS:

Tapp pod requires higher iOS
→ platform :ios, '14.0' (or higher) and re-run pod install.

Cache weirdness
→ flutter clean && rm -rf ios/Pods ios/Podfile.lock && pod repo update && pod install.

🔐 Minimum versions

Android: minSdk 24, compileSdk 34, Java/Kotlin 17

iOS: iOS 14.0+

📄 License
MIT © Tapp
```
