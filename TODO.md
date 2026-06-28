# CardScan iOS — Feature Roadmap

Build order follows the web app's 3-step flow: **Capture → Review → Export**,
plus cross-cutting concerns (design system, persistence, history).

---

## Phase 0 — Project Setup

- [ ] Create Xcode project (`CardScan`, SwiftUI, iOS 16 deployment target)
- [ ] Set bundle ID: `com.sapienwilson.cardscan`
- [ ] Configure `Info.plist` — add camera & photo library usage descriptions
- [ ] Set up folder structure matching `README.md`
- [ ] Add app icon (port from web `icons/icon-192.png`)
- [ ] Configure accent color (`#01696f` light / `#4f98a3` dark)
- [ ] Set up SwiftUI `@main` entry and root `NavigationStack`

---

## Phase 1 — Design System

Map web CSS tokens → SwiftUI equivalents.

- [ ] `DesignTokens.swift` — Color, Typography, Spacing, Radius enums
- [ ] `Color+CardScan.swift` — semantic color extensions (light + dark)
  - Primary: `#01696f` / `#4f98a3`
  - Background: `#f7f6f2` / `#171614`
  - Surface: `#f9f8f5` / `#1c1b19`
  - Text muted: `#7a7974` / `#797876`
  - Success: `#437a22` / `#6daa45`
- [ ] `Font+CardScan.swift` — Inter (body) + Instrument Serif (display)
  - Add font files to `Resources/` or use system SF Pro as fallback
- [ ] Reusable button styles: `PrimaryButtonStyle`, `SecondaryButtonStyle`, `GhostButtonStyle`
- [ ] `CardScanCard` container view (surface background, rounded corners, shadow)
- [ ] `StepIndicator` view (mirrors web 1 → 2 → 3 progress row)
- [ ] Toast notification view (`ToastView` + `ToastModifier`)

---

## Phase 2 — Capture

**Web equivalent:** `panel-capture`, camera panel, drag-drop upload zone.

- [ ] `CaptureView.swift` — root capture screen
- [ ] `PhotoImportButton` — calls `PHPickerViewController` (photo library)
- [ ] `CameraView.swift` — `UIViewRepresentable` wrapping `AVCaptureSession`
  - [ ] Rear camera default, front camera flip button
  - [ ] Torch/flash toggle (bonus)
  - [ ] Card-guide overlay rectangle (SwiftUI overlay on top of preview)
  - [ ] Capture button (shutter)
- [ ] `ImagePreprocessor.swift` — Core Image pipeline
  - [ ] Scale to min 1800px wide
  - [ ] Grayscale (`CIColorControls` saturation = 0)
  - [ ] Contrast stretch (`CIColorControls` contrast)
  - [ ] Sharpen (`CIUnsharpMask`)
  - [ ] Adaptive threshold (custom `CIFilter` or `vImage`)
  - [ ] Skew detection + correction (`CIPerspectiveCorrection`)

---

## Phase 3 — OCR & Parsing

**Web equivalent:** Tesseract.js + `parseContactFields()`.

- [ ] `OCREngine.swift` — wraps `VNRecognizeTextRequest`
  - [ ] `recognitionLevel = .accurate`
  - [ ] `usesLanguageCorrection = true`
  - [ ] Returns `[String]` of recognized lines + full raw text
- [ ] `ContactParser.swift` — maps raw OCR lines → `ContactFields` model
  - [ ] Email regex
  - [ ] Phone regex (supports +1, extensions)
  - [ ] URL / website detection
  - [ ] LinkedIn URL detection
  - [ ] Address detection (State + ZIP pattern)
  - [ ] Name heuristic (2–5 words, no digits, shortest candidate)
  - [ ] Title keyword matching (CEO, Director, Manager, etc.)
  - [ ] Company fallback
- [ ] `ProcessingView.swift` — spinner + progress bar while OCR runs
  - [ ] Show "Running OCR…" status text
  - [ ] Async/await task, cancellable

---

## Phase 4 — Review

**Web equivalent:** `panel-review` with editable form grid.

- [ ] `ContactFields.swift` — `Codable` struct (name, title, company, phone, phone2, email, website, address, linkedin, notes)
- [ ] `ReviewView.swift` — scrollable form
  - [ ] Scanned card image thumbnail at top
  - [ ] Editable `TextField` per contact field with label + icon
  - [ ] "Show raw OCR text" expandable section
  - [ ] "Continue to Export" primary button
  - [ ] "Scan Another" ghost button
- [ ] Keyboard handling — `ScrollViewReader` to scroll to focused field

---

## Phase 5 — Export

**Web equivalent:** `panel-export`, vCard preview card, Download + Copy buttons.

- [ ] `vCardPreviewCard.swift` — teal gradient card showing name, title/company, contact fields with icons
- [ ] `ExportView.swift`
  - [ ] "Save to Contacts" button — `CNContact` + `CNContactStore.save()`
  - [ ] "Download .vcf" button — write `CNContactVCardSerialization` data to temp file → `ShareLink`
  - [ ] "Copy as Text" button — `UIPasteboard.general.string`
  - [ ] "Edit Fields" back button
  - [ ] "Scan Another" reset button
- [ ] Request Contacts permission gracefully (show rationale if denied)

---

## Phase 6 — Scan History

**Web equivalent:** history drawer, badge, per-item re-export and delete.

- [ ] `HistoryEntry.swift` — `Codable` struct (id, scannedAt, fields, thumbnailData)
- [ ] `HistoryStore.swift` — `ObservableObject`, persists to `UserDefaults` (max 50 entries)
- [ ] History saved automatically on export (VCF or Copy)
- [ ] `HistoryDrawer.swift` — slides in from trailing edge (`.sheet` or custom `NavigationSplitView`)
  - [ ] Badge count on toolbar button
  - [ ] Per-item: thumbnail, name, subtitle, date
  - [ ] Per-item actions: re-export VCF (swipe or button), delete
  - [ ] "Clear All" with confirmation alert
  - [ ] Empty state illustration + message

---

## Phase 7 — Polish & Release

- [ ] App icon all sizes (generate from web `icon-512.png`)
- [ ] Launch screen / splash
- [ ] Accessibility — VoiceOver labels, Dynamic Type support
- [ ] `@AppStorage` for dark mode preference (follow system by default)
- [ ] Haptic feedback on capture shutter and export
- [ ] Error handling — camera denied, contacts denied, OCR failure alerts
- [ ] Unit tests — `ContactParser`, `vCard` generation
- [ ] TestFlight build
- [ ] App Store submission

---

## Web → Native API Mapping (quick reference)

| Web (CardScan) | Native iOS |
|---|---|
| `<video>` + `getUserMedia` | `AVCaptureSession` + `AVPreviewLayer` |
| Canvas grayscale / threshold | `CIColorControls`, `vImage`, custom `CIFilter` |
| Tesseract.js WASM | `Vision.VNRecognizeTextRequest` |
| `parseContactFields()` JS | `ContactParser.swift` |
| `.vcf` Blob download | `CNContactVCardSerialization` + `ShareLink` |
| `navigator.clipboard` | `UIPasteboard.general` |
| `localStorage` | `UserDefaults` (Codable) |
| CSS design tokens | `Color+CardScan.swift`, `Font+CardScan.swift` |
| History drawer slide-in | SwiftUI `.sheet` or custom trailing `NavigationSplitView` |
| Toast notification | Custom `ToastModifier` with `.animation` |
