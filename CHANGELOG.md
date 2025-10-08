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
