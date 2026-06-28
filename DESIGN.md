# CardScan iOS — Design Token Reference

This document maps the web app's CSS custom properties to their SwiftUI equivalents.
All SwiftUI colors should be defined as `Color` extensions in `Shared/Design/Color+CardScan.swift`
with both light and dark variants using `UITraitCollection` or `Color(light:dark:)`.

---

## Colors

### Light Mode

| Token | Hex | Usage |
|---|---|---|
| `bg` | `#f7f6f2` | App background |
| `surface` | `#f9f8f5` | Card / panel background |
| `surface2` | `#ffffff` | Input field background |
| `surfaceOffset` | `#f0ede8` | Subtle inset areas |
| `divider` | `#dcd9d5` | Separator lines |
| `border` | `#d4d1ca` | Input borders |
| `text` | `#28251d` | Primary text |
| `textMuted` | `#7a7974` | Secondary text, labels |
| `textFaint` | `#bab9b4` | Placeholders, meta |
| `primary` | `#01696f` | Buttons, links, active states |
| `primaryHover` | `#0c4e54` | Pressed primary |
| `primaryHighlight` | `#cedcd8` | Primary tint background |
| `success` | `#437a22` | Success button, badge |
| `successHighlight` | `#d4dfcc` | Success tint background |

### Dark Mode

| Token | Hex | Usage |
|---|---|---|
| `bg` | `#171614` | App background |
| `surface` | `#1c1b19` | Card / panel background |
| `surface2` | `#201f1d` | Input field background |
| `surfaceOffset` | `#1d1c1a` | Subtle inset areas |
| `divider` | `#262523` | Separator lines |
| `border` | `#393836` | Input borders |
| `text` | `#cdccca` | Primary text |
| `textMuted` | `#797876` | Secondary text, labels |
| `textFaint` | `#5a5957` | Placeholders, meta |
| `primary` | `#4f98a3` | Buttons, links, active states |
| `primaryHover` | `#227f8b` | Pressed primary |
| `primaryHighlight` | `#313b3b` | Primary tint background |
| `success` | `#6daa45` | Success button, badge |
| `successHighlight` | `#3a4435` | Success tint background |

---

## Typography

| Role | Web | SwiftUI |
|---|---|---|
| Display / headings | Instrument Serif | `Font.custom("InstrumentSerif-Regular", size:)` |
| Body | Inter | `Font.custom("Inter-Regular", size:)` — or SF Pro fallback |
| `text-xs` | clamp 12–14px | `.caption` (~12pt) |
| `text-sm` | clamp 14–16px | `.subheadline` (~15pt) |
| `text-base` | clamp 16–18px | `.body` (~17pt) |
| `text-lg` | clamp 18–24px | `.title3` (~20pt) |
| `text-xl` | clamp 24–36px | `.title` (~28pt) |

> Add `Inter` and `Instrument Serif` font files to `Resources/Fonts/`
> and declare them in `Info.plist` under `UIAppFonts`.

---

## Spacing Scale

| Token | Value | Points (approx) |
|---|---|---|
| `space-1` | 0.25rem | 4pt |
| `space-2` | 0.5rem | 8pt |
| `space-3` | 0.75rem | 12pt |
| `space-4` | 1rem | 16pt |
| `space-5` | 1.25rem | 20pt |
| `space-6` | 1.5rem | 24pt |
| `space-8` | 2rem | 32pt |
| `space-10` | 2.5rem | 40pt |
| `space-12` | 3rem | 48pt |
| `space-16` | 4rem | 64pt |

Define as a `Spacing` enum with static `CGFloat` constants in `Shared/Design/Spacing.swift`.

---

## Corner Radius

| Token | Value |
|---|---|
| `radius-sm` | 6pt |
| `radius-md` | 8pt |
| `radius-lg` | 12pt |
| `radius-xl` | 16pt |
| `radius-full` | 9999pt (use `.infinity` in SwiftUI) |

---

## Shadows

| Token | SwiftUI equivalent |
|---|---|
| `shadow-sm` | `.shadow(color: .black.opacity(0.07), radius: 2, y: 1)` |
| `shadow-md` | `.shadow(color: .black.opacity(0.09), radius: 8, y: 4)` |
| `shadow-lg` | `.shadow(color: .black.opacity(0.13), radius: 20, y: 12)` |

---

## Component Notes

### Primary Button
```swift
// Background: Color.cardScanPrimary
// Foreground: .white
// Corner radius: radius-md (8pt)
// Padding: 12pt vertical, 20pt horizontal
// Press state: scale(0.98), darker background
```

### vCard Preview Card
```swift
// Linear gradient: primary → primaryHover, angle 135°
// Corner radius: radius-xl (16pt)
// Shadow: shadow-lg
// Name font: Instrument Serif, text-xl
// Decorative circle: white at 6% opacity, top-right
```

### Toast
```swift
// Background: success color
// Fixed bottom-right, 24pt inset
// Slides up with spring animation, fades out after 3.2s
// Checkmark icon + message text
```
