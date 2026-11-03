## 2.0.0 - 2026-11-DD

### Breaking

- Minimum iOS is now 15.0, required by Tapp 1.1.23 / Tapp-Adjust 1.1.26 / Tapp-Networking 1.1.7. Apps targeting iOS 13 or 14 must raise their deployment target.

### Changed

- Pinned iOS native dependencies:
  - `Tapp` `1.1.23`
  - `Tapp-Adjust` `1.1.26`
  - `Tapp-Networking` `1.1.7`
- Tapp-Adjust 1.1.26 raises its iOS minimum to 15.0 and requires Tapp 1.1.23 / Tapp-Networking 1.1.7 or later. It has no source changes.
- Updated Android `Tapp-Adjust` native dependency to `1.1.6`:
  - When the backend reports that a deep-link impression was already counted for the device (for example, a reinstall within about 90 days), the deferred link is now delivered (`onDeferredLinkReceived`) instead of a resolve failure (`onDidFailResolvingURL`).
  - Tapp-Core now declares `android.permission.INTERNET`, which is merged into consuming apps. Adjust integrations already received this permission from the Adjust SDK.
- Native-only 1.1.6 fixes (install-referrer handling and its retry) do not apply to Adjust integrations.
- No public Dart API, model, method-channel, or native bridge signature changes. The affiliate remains Adjust.

## 1.1.1 - 2026-07-06

### Changed

- Updated Android `Tapp-Adjust` native dependency to `1.1.5`.
- Pinned iOS native dependencies to tested versions:
  - `Tapp` `1.1.22`
  - `Tapp-Adjust` `1.1.25`
  - `Tapp-Networking` `1.1.6`
- No public Dart API or native bridge signature changes.

## 1.1.0 – 2026-03-26

### Changed

- `simulateTestEvent()` is no longer part of the active public Dart API surface.
- README reworked into an integration-first guide with a clear onboarding flow:
  prerequisites, installation, deep-link setup, checklist, minimal integration, verification, bootstrap pattern, common flows, platform notes, troubleshooting.
- Deep-link documentation now explicitly separates:
  - what clients configure (Tapp dashboard + native iOS/Android link handling)
  - what Tapp manages (`apple-app-site-association` and `assetlinks.json` after dashboard setup)
- Added dashboard deep-link field alignment guidance, including:
  - `SHA-256 Certificate Fingerprint`
  - `Android App Scheme`
  - `App ID Prefix`
  - `iOS App Scheme`
- Example app updated to remove test-event simulation UI/listener tied to the removed test-only API.

### Metadata

- Added publish metadata links in `pubspec.yaml`:
  - `issue_tracker`
  - `documentation`

## 1.0.2 – 2025-10-08

### Changed

- **Affiliate is now hardcoded to Adjust on both platforms.**
  - **iOS:** `initialize` now builds `TappConfiguration` with `affiliate: .adjust` (enum-based initializer), ignoring any `affiliate` string passed from Dart.
  - **Android:** `initialize` now starts Tapp with `Affiliate.ADJUST`, ignoring any `affiliate` argument from Dart.
- The `environment` handling on iOS now uses the enum-based initializer (`.production` / `.sandbox`) for stricter typing.

### Notes / Migration

- The Dart API still accepts an `affiliate` parameter for compatibility, but it is **ignored** on both iOS and Android and will always use **Adjust**.
- If your app relied on switching affiliates at runtime, please plan accordingly. The `affiliate` parameter is considered **deprecated** and may be removed in a future major release.

### Documentation

- README updated to clarify that Adjust is the enforced affiliate on both platforms.
