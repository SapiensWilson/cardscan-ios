import UIKit

/// Centralised haptic feedback helpers.
/// Uses UIKit generators so they work on iOS 16+.
enum Haptics {

    // MARK: — Notification feedback

    /// Play a success notification haptic (export, save).
    static func success() {
        let g = UINotificationFeedbackGenerator()
        g.prepare()
        g.notificationOccurred(.success)
    }

    /// Play an error notification haptic (permission denied, OCR failure).
    static func error() {
        let g = UINotificationFeedbackGenerator()
        g.prepare()
        g.notificationOccurred(.error)
    }

    /// Play a warning notification haptic.
    static func warning() {
        let g = UINotificationFeedbackGenerator()
        g.prepare()
        g.notificationOccurred(.warning)
    }

    // MARK: — Impact feedback

    /// Light tap — button presses, row taps.
    static func light() {
        let g = UIImpactFeedbackGenerator(style: .light)
        g.prepare()
        g.impactOccurred()
    }

    /// Medium impact — shutter capture.
    static func medium() {
        let g = UIImpactFeedbackGenerator(style: .medium)
        g.prepare()
        g.impactOccurred()
    }

    /// Heavy impact — destructive actions (clear history).
    static func heavy() {
        let g = UIImpactFeedbackGenerator(style: .heavy)
        g.prepare()
        g.impactOccurred()
    }
}
