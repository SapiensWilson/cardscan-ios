# CardScan iOS

> Native iOS companion to [CardScan Web](https://github.com/SapiensWilson/cardscan).  
> On-device business card OCR → contact review → vCard export.  
> **No cloud. No subscription. 100% local.**

![Platform](https://img.shields.io/badge/platform-iOS%2016%2B-black?logo=apple)
![Swift](https://img.shields.io/badge/Swift-5.9-orange?logo=swift)
![License](https://img.shields.io/badge/license-MIT-green)

---

## Features (planned v1)

- 📷 Camera capture with card-guide overlay (AVFoundation)
- 🖼 Photo library import
- 🔍 On-device OCR via Apple Vision framework (no Tesseract needed)
- ✏️ Editable contact field review (Name, Title, Company, Phone, Email, Website, Address, LinkedIn, Notes)
- 📇 vCard export (.vcf) via Contacts framework
- 🕓 Scan history with thumbnails (stored in UserDefaults / CoreData)
- 🌙 Dark mode — matches web app design tokens
- 📴 Fully offline — zero network calls

## Tech Stack

| Concern | Technology |
|---|---|
| UI | SwiftUI |
| OCR | Vision (`VNRecognizeTextRequest`) |
| Camera | AVFoundation |
| Image processing | Core Image |
| Contact export | Contacts + CNContactVCardSerialization |
| Persistence | UserDefaults (history), Codable models |
| Min deployment | iOS 16.0 |
| Xcode | 15+ |

## Project Structure

```
cardscan-ios/
├── CardScan/                    # Xcode project root (to be created)
│   ├── App/
│   │   ├── CardScanApp.swift    # @main entry point
│   │   └── AppState.swift       # ObservableObject global state
│   ├── Features/
│   │   ├── Capture/             # Camera + photo import
│   │   ├── Processing/          # Image pre-processing pipeline
│   │   ├── Review/              # Editable contact form
│   │   ├── Export/              # vCard preview + export
│   │   └── History/             # Scan history drawer
│   ├── Shared/
│   │   ├── Design/              # Tokens: Colors, Typography, Spacing
│   │   ├── Models/              # ContactFields.swift, HistoryEntry.swift
│   │   └── Components/          # Reusable UI components
│   ├── Resources/
│   │   ├── Assets.xcassets      # App icon, accent color
│   │   └── Info.plist
│   └── CardScan.xcodeproj
├── TODO.md                      # Feature roadmap
├── DESIGN.md                    # Design token reference
└── README.md
```

## Getting Started

> ⚠️ Xcode project scaffold coming soon. See [TODO.md](TODO.md) for build order.

1. Clone the repo
2. Open `CardScan/CardScan.xcodeproj` in Xcode 15+
3. Select your simulator or device
4. Build & run — no dependencies, no package manager needed

## Design

This app mirrors the web app's visual language. See [DESIGN.md](DESIGN.md) for the full token reference (colors, typography, spacing, radius).

## License

MIT — same as the web app.
