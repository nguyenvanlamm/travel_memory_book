# iOS Setup Guide for Travel Memory Book

## ✅ Completed on Linux

### 1. iOS Platform Added
```bash
flutter create --platforms=ios .
```
Created `app/ios/` with Xcode project structure.

### 2. Info.plist Permissions Configured
Added required privacy descriptions:
- `NSCameraUsageDescription` - Camera access for travel photos
- `NSPhotoLibraryUsageDescription` - Photo library access for importing memories
- `NSPhotoLibraryAddUsageDescription` - Save generated books to library
- `ITSAppUsesNonExemptEncryption` - Set to false (no encryption)

### 3. App Icons Generated
```bash
flutter pub run flutter_launcher_icons
```
- Source: `store-metadata/icon/icon-512.png`
- Generated all iOS sizes (20x20 to 1024x1024)
- `remove_alpha_ios: true` configured (App Store requirement)

### 4. ExportOptions.plist Created
Template for App Store distribution at `app/ios/ExportOptions.plist`

### 5. Fastlane Configuration
Created in `app/ios/fastlane/`:
- `Appfile` - App identifier, team ID
- `Fastfile` - Lanes: `certificates`, `build`, `beta` (TestFlight), `release` (App Store), `test`
- `Matchfile` - Certificate management via git
- `.env.example` - Environment variables template

### 6. GitHub Actions CI/CD
Created `.github/workflows/ios-build.yml`:
- Builds on macOS runner
- Installs Flutter, CocoaPods, fastlane
- Runs `flutter build ipa`
- Deploys to TestFlight (on push) or App Store (manual)
- Creates GitHub Release with IPA artifact

---

## 🔧 Required on macOS

### Prerequisites
1. **Apple Developer Program** ($99/year) - Required for TestFlight/App Store
2. **Xcode 15+** installed
3. **macOS** (Intel or Apple Silicon)

### First-Time Setup on Mac

```bash
# 1. Clone repo
git clone <your-repo>
cd travel_memory_book

# 2. Install Flutter (if not installed)
# https://docs.flutter.dev/get-started/install/macos

# 3. Navigate to app
cd app

# 4. Get dependencies
flutter pub get

# 5. Install CocoaPods
cd ios
pod install --repo-update
cd ..

# 6. Open in Xcode
open ios/Runner.xcworkspace
```

### Xcode Configuration
1. Select **Runner** project → **Signing & Capabilities**
2. Set **Team** to your Apple Developer Team
3. Verify **Bundle Identifier**: `com.lam.travelmemorybook`
4. Enable **Automatically manage signing**

### Fastlane Match Setup (Recommended)
```bash
cd ios/fastlane

# 1. Initialize match (first time only)
fastlane match init

# 2. Create certificates repo (private GitHub repo)
#    Follow prompts to set up git repo for certs

# 3. Generate certificates
fastlane match appstore

# 4. This creates:
#    - Distribution certificate
#    - App Store provisioning profile
#    Both stored encrypted in your certificates repo
```

### App Store Connect Setup
1. Create app at https://appstoreconnect.apple.com
2. Bundle ID: `com.lam.travelmemorybook`
3. Generate **App Store Connect API Key**:
   - Users and Access > Keys > Generate API Key
   - Role: App Manager or Admin
   - Download `.p8` file
   - Note: Key ID and Issuer ID

### GitHub Secrets (Required for CI/CD)
Add to repository Settings > Secrets > Actions:

| Secret | Description |
|--------|-------------|
| `TEAM_ID` | 10-char Apple Developer Team ID |
| `APP_STORE_CONNECT_API_KEY` | Base64 encoded `.p8` file |
| `APP_STORE_CONNECT_API_KEY_ID` | Key ID from App Store Connect |
| `APP_STORE_CONNECT_API_ISSUER_ID` | Issuer ID from App Store Connect |
| `MATCH_PASSWORD` | Password for match certificates repo |
| `MATCH_GIT_URL` | Git URL for certificates repo (private) |

---

## 🚀 Build Commands

### Local Build (macOS)
```bash
cd app

# Development build
flutter build ipa --debug

# Release build for App Store
flutter build ipa --release \
  --export-options-plist=ios/ExportOptions.plist \
  --build-name=1.0.0 \
  --build-number=1
```

### Fastlane Build
```bash
cd app/ios

# Sync certificates
fastlane certificates

# Build only
fastlane build

# Build + upload to TestFlight
fastlane beta

# Build + submit to App Store
fastlane release
```

### CI/CD Trigger
```bash
# Push tag to trigger build + TestFlight deploy
git tag v1.0.0
git push origin v1.0.0

# Manual workflow dispatch for App Store
# GitHub Actions > iOS Build & Deploy > Run workflow
```

---

## 📱 Required Assets Checklist

- [x] App Icon (1024x1024) - Generated from 512px source
- [ ] Launch Screen - Customize `ios/Runner/Base.lproj/LaunchScreen.storyboard`
- [x] Screenshots placeholders - Replace in `store-metadata/screenshots/`
  - iPhone 6.7" (1290×2796)
  - iPhone 6.5" (1242×2688)
  - iPad Pro 12.9" (2048×2732)
- [ ] Privacy Policy - Host at `https://travelmemorybook.app/privacy`
- [ ] App metadata - Fill in App Store Connect

---

## 🐛 Troubleshooting

### "Provisioning profile doesn't match"
- Run `fastlane match appstore` to refresh
- Verify Bundle ID matches in Xcode and App Store Connect

### "Bitcode" errors
- Already disabled in ExportOptions.plist (`compileBitcode: false`)

### "Alpha channel in icons"
- Fixed with `remove_alpha_ios: true` in flutter_launcher_icons config

### Build fails on CI
- Check macOS runner version matches Xcode requirement
- Verify all secrets are set correctly
- Check fastlane match certificates repo access

---

## 📝 Version Management

Update version in `pubspec.yaml`:
```yaml
version: 1.0.0+1  # format: major.minor.patch+build_number
```

CI/CD auto-syncs:
- `CFBundleShortVersionString` = 1.0.0
- `CFBundleVersion` = 1 (build number)

---

## 🔗 Useful Links

- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)
- [Fastlane Match](https://docs.fastlane.tools/actions/match/)
- [App Store Connect API](https://developer.apple.com/app-store-connect/api/)
- [GitHub Actions macOS](https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners#supported-runners-and-hardware-resources)