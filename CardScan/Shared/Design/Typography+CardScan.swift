import SwiftUI

extension Font {
    /// Instrument Serif — display / headings. Falls back to Georgia.
    static func csDisplay(size: CGFloat) -> Font {
        Font.custom("InstrumentSerif-Regular", size: size)
            .fallback(.init(.system(.body))) // Xcode resolves at runtime
    }

    /// Instrument Serif Italic.
    static func csDisplayItalic(size: CGFloat) -> Font {
        Font.custom("InstrumentSerif-Italic", size: size)
    }

    // MARK: — Inter scale (mirrors CSS clamp tokens)
    /// ~12pt — captions, meta, badges
    static let csXS:   Font = .custom("Inter-Regular",   fixedSize: 12)
    /// ~14pt — labels, secondary text
    static let csSM:   Font = .custom("Inter-Regular",   fixedSize: 14)
    /// ~14pt semibold
    static let csSMSB: Font = .custom("Inter-SemiBold",  fixedSize: 14)
    /// ~16pt — body
    static let csBase: Font = .custom("Inter-Regular",   fixedSize: 16)
    /// ~16pt semibold
    static let csBaseSB: Font = .custom("Inter-SemiBold", fixedSize: 16)
    /// ~20pt — section titles
    static let csLG:   Font = .custom("Inter-SemiBold",  fixedSize: 20)
}

/*
 SETUP: Add Inter and Instrument Serif font files to CardScan/Resources/Fonts/
 Then declare them in Info.plist under "Fonts provided by application" (UIAppFonts):

   Inter-Regular.ttf
   Inter-Medium.ttf
   Inter-SemiBold.ttf
   Inter-Bold.ttf
   InstrumentSerif-Regular.ttf
   InstrumentSerif-Italic.ttf

 Fonts are available free from Google Fonts.
*/
