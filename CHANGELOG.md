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
