# CardScan iOS — Xcode Setup Checklist

Everything you need to do in Xcode before the app builds and runs.
All Swift source files are already in the repo — this guide covers the
project scaffolding that can only be done locally.

---

## 1. Create the Xcode Project

1. Open **Xcode 15+**
2. **File → New → Project…** → choose **App** (iOS)
3. Fill in the fields:
   | Field | Value |
   |---|---|
   | Product Name | `CardScan` |
   | Bundle Identifier | `com.sapienwilson.cardscan` |
   | Interface | SwiftUI |
   | Language | Swift |
   | Minimum Deployment | iOS 16.0 |
4. **Uncheck** “Create Git repository” (you already have one)
5. Save into your local clone **at the repo root** → `cardscan-ios/CardScan/`
6. Delete the auto-generated `ContentView.swift` — it is replaced by the files in this repo

---

## 2. Add Source Files to the Project

In the **Project Navigator** (left panel):

1. Right-click the `CardScan` group → **Add Files to “CardScan”…**
2. Select the following folders (tick **“Create groups”**, not folder references):
   - `App/`
   - `Features/`
   - `Shared/`
3. Click **Add**

You should now see these groups in the navigator:
```
CardScan
├── App
├── Features
│   ├── Capture
│   ├── Processing
│   ├── Review
│   ├── Export
│   └── History
└── Shared
    ├── Design
    ├── Components
    ├── Models
    └── Support
```

---

## 3. Add Color Assets

Open `CardScan/Resources/Assets.xcassets`.

For each color name below, right-click in the asset list →
**New Color Set** → set the name exactly as shown → set
**Appearances** to **Any, Dark** → enter the hex values.

| Asset name | Light (Any) | Dark |
|---|---|---|
| `csBg` | `#f7f6f2` | `#171614` |
| `csSurface` | `#f9f8f5` | `#1c1b19` |
| `csSurface2` | `#ffffff` | `#201f1d` |
| `csSurfaceOffset` | `#f0ede8` | `#1d1c1a` |
| `csSurfaceDynamic` | `#e6e4df` | `#2d2c2a` |
| `csDivider` | `#dcd9d5` | `#262523` |
| `csBorder` | `#d4d1ca` | `#393836` |
| `csText` | `#28251d` | `#cdccca` |
| `csTextMuted` | `#7a7974` | `#797876` |
| `csTextFaint` | `#bab9b4` | `#5a5957` |
| `csTextInverse` | `#f9f8f4` | `#2b2a28` |
| `csGreen` | `#01696f` | `#4f98a3` |
| `csGreenHover` | `#0c4e54` | `#227f8b` |
| `csGreenActive` | `#0f3638` | `#1a626b` |
| `csGreenHighlight` | `#cedcd8` | `#313b3b` |
| `csSuccess` | `#437a22` | `#6daa45` |
| `csSuccessHover` | `#2e5c10` | `#4d8f25` |
| `csSuccessHighlight` | `#d4dfcc` | `#3a4435` |

> **Tip:** In each color set, click the color swatch → Attributes Inspector
> → set **Input Method** to **8-bit Hexadecimal** to paste hex values directly.

---

## 4. Add Fonts

### Get the fonts (free)
- **Inter** — https://fonts.google.com/specimen/Inter
  Download: Regular, Medium, SemiBold, Bold
- **Instrument Serif** — https://fonts.google.com/specimen/Instrument+Serif
  Download: Regular, Italic

### Add to project
1. Create `CardScan/Resources/Fonts/` folder
2. Copy these files into it:
   ```
   Inter-Regular.ttf
   Inter-Medium.ttf
   Inter-SemiBold.ttf
   Inter-Bold.ttf
   InstrumentSerif-Regular.ttf
   InstrumentSerif-Italic.ttf
   ```
3. In Xcode, drag the `Fonts/` folder into the navigator
   → tick **“Add to target: CardScan”** → click **Add**

### Declare in Info.plist
Add an array key `UIAppFonts` (Fonts provided by application):
```xml
<key>UIAppFonts</key>
<array>
  <string>Inter-Regular.ttf</string>
  <string>Inter-Medium.ttf</string>
  <string>Inter-SemiBold.ttf</string>
  <string>Inter-Bold.ttf</string>
  <string>InstrumentSerif-Regular.ttf</string>
  <string>InstrumentSerif-Italic.ttf</string>
</array>
```

---

## 5. Add Privacy Usage Descriptions (Info.plist)

In Xcode: select `CardScan` target → **Info** tab → click **+** to add keys.

Or paste directly into `Info.plist`:

```xml
<!-- Camera -->
<key>NSCameraUsageDescription</key>
<string>CardScan needs camera access to photograph business cards.</string>

<!-- Photo Library -->
<key>NSPhotoLibraryUsageDescription</key>
<string>CardScan needs photo library access to import business card images.</string>

<!-- Contacts -->
<key>NSContactsUsageDescription</key>
<string>CardScan uses Contacts to save scanned business cards to your address book.</string>
```

> ⚠️ The app **will crash** on first launch if any of these three keys are missing
> when the corresponding permission is requested.

---

## 6. Set Deployment Target & Capabilities

1. Select the `CardScan` target → **General** tab
2. Set **Minimum Deployments** to **iOS 16.0**
3. Under **Signing & Capabilities**:
   - Set your **Team** to your Apple ID / developer account
   - Bundle ID: `com.sapienwilson.cardscan`
   - No additional capabilities needed (Vision, Contacts, AVFoundation, Photos are all framework-level, no entitlements required)

---

## 7. App Icon

1. In `Assets.xcassets`, select **AppIcon**
2. The icon slot requires a single 1024×1024 px PNG (Xcode 13+ universal method)
3. You can generate one from the web app’s `icons/icon-512.png`:
   - Scale up to 1024×1024 in any image editor
   - Drag it into the AppIcon slot in Assets.xcassets

---

## 8. Build & Run

1. Select your target device or simulator (iPhone 14 / 15 / 16 recommended)
2. Press **⌘R** to build
3. Expected result: the app launches showing the Capture screen with the CardScan logo

### If you get font-not-found warnings
Check that the font filenames in `Info.plist` exactly match the `.ttf` file names (case-sensitive). The app falls back gracefully to system fonts so it will still run.

### If camera doesn’t work in Simulator
The iOS Simulator has no camera — use **Upload Image** instead, or run on a physical device.

---

## 9. Test the Full Flow

| Step | What to test |
|---|---|
| Upload | Tap “Upload Image” → pick a photo of a business card |
| Processing | Watch spinner + progress bar |
| Review | Verify parsed fields, edit if needed |
| Export | Tap “Save to Contacts” — accept permission prompt |
| History | Tap clock icon → confirm the scan was saved |
| Dark mode | Change Simulator Appearance → Dark to verify all tokens |
| VoiceOver | Enable VoiceOver in Simulator → verify labels on all controls |

---

## 10. TestFlight (when ready)

1. **Product → Archive**
2. In Organizer → **Distribute App → TestFlight**
3. Follow App Store Connect prompts
4. Add testers under **TestFlight → Internal Testing**

---

## Quick Reference — Key Files

| File | Purpose |
|---|---|
| `App/CardScanApp.swift` | `@main` entry point |
| `App/AppState.swift` | Global state, alerts, toast |
| `App/RootView.swift` | Navigation shell + toolbar |
| `Shared/Design/Color+CardScan.swift` | All semantic color tokens |
| `Shared/Design/Typography+CardScan.swift` | Font helpers |
| `Shared/Design/Spacing.swift` | Spacing + radius constants |
| `Shared/Design/ButtonStyles.swift` | PrimaryButtonStyle etc. |
| `Shared/Support/Haptics.swift` | Haptic feedback helpers |
| `Shared/Support/AppAlert.swift` | Identifiable alert model |
| `Shared/Support/PermissionHelper.swift` | Camera permission flow |
| `Features/Capture/CaptureView.swift` | Flow router (all 4 steps) |
| `Features/Capture/CameraView.swift` | AVFoundation camera |
| `Features/Processing/ImagePreprocessor.swift` | Core Image pipeline |
| `Features/Processing/OCREngine.swift` | Vision OCR wrapper |
| `Features/Processing/ScanPipeline.swift` | Pipeline orchestrator |
| `Features/Processing/ContactParser.swift` | OCR → ContactFields |
| `Features/Review/ReviewView.swift` | Editable contact form |
| `Features/Export/ExportView.swift` | Save / Share / Copy |
| `Features/Export/VCardBuilder.swift` | CNContact + .vcf builder |
| `Features/History/HistoryStore.swift` | UserDefaults persistence |
| `Features/History/HistoryDrawer.swift` | History sheet |
