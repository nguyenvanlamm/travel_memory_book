# Privacy Policy for Travel Memory Book

**Effective Date:** August 29, 2026  
**App Version:** 1.0.0  
**Developer:** Lam (personal project)

---

## 1. Overview

Travel Memory Book ("the App") is a personal travel journal designed to help you preserve your travel memories as digital photo books. This privacy policy explains what information the App handles and how it is protected.

**Key Principle:** Your data belongs to you. The App does not collect, transmit, or share any personal data with the developer or any third parties.

---

## 2. Information We Do Not Collect

The App does **not** collect, store, or transmit any of the following:

- Personal identification information (name, email, phone number)
- Location data beyond what you explicitly add to your trips
- Usage analytics or tracking data
- Device identifiers or advertising IDs
- Crash reports or error logs (no crash reporting SDKs are included)
- Any data for advertising or marketing purposes

---

## 3. Data Stored on Your Device

All data created in the App is stored **locally on your device only**:

- **Trip data:** Titles, descriptions, dates, countries, cities
- **Photos:** Original images and generated thumbnails (stored in app-private storage)
- **Memories:** Written notes for trips, days, or individual photos
- **EXIF metadata:** Date taken, GPS coordinates, camera info (read from your photos)
- **App preferences:** Theme choice (light/dark/system)

This data is stored using:
- **Isar database** (local NoSQL database)
- **App-private file storage** (photos and thumbnails)
- **SharedPreferences** (theme preference only)

---

## 4. Permissions Used

The App requests only the permissions necessary for its core functionality:

| Permission | Purpose |
|------------|---------|
| `CAMERA` | Take photos directly within the App |
| `READ_MEDIA_IMAGES` / `READ_EXTERNAL_STORAGE` | Select photos from your gallery |
| `WRITE_EXTERNAL_STORAGE` (legacy) | Save photos on older Android versions |

**No network permissions** are requested (`INTERNET` permission is not declared).

---

## 5. Data Sharing

The App does **not** share any data with:

- The developer
- Third-party services
- Advertising networks
- Analytics providers
- Cloud backup services (not implemented in current version)

If you choose to export data (e.g., PDF export in future versions), you control where that file goes.

---

## 6. Data Retention and Deletion

- All data remains on your device until you delete it
- Uninstalling the App deletes all associated data
- You can delete individual trips, photos, or memories at any time
- No data persists after uninstallation

---

## 7. Children's Privacy

The App is not directed at children under 13. It does not knowingly collect personal information from children.

---

## 8. Security

- All data is stored in the App's private sandbox (Android app sandbox)
- No data is transmitted over the network
- No encryption keys are stored (data is not encrypted beyond OS-level protection)
- Photos are stored as-is without re-compression

---

## 9. Changes to This Policy

If the App's data practices change in future versions, this policy will be updated and the effective date will be changed. Continued use of the App after changes constitutes acceptance of the updated policy.

---

## 10. Contact

For questions about this privacy policy or the App's data practices:

**Developer:** Lam  
**Contact:** [Add your contact email here]  
**App:** Travel Memory Book

---

*This privacy policy is generated from the App's actual data practices as implemented in version 1.0.0. It reflects the actual behavior of the code — no claims are made about practices that are not implemented in the App.*
