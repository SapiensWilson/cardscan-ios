import Foundation

/// Identifiable alert model used with .alert(item:) across the app.
/// Each case maps to a title + message + optional settings-redirect action.
struct AppAlert: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    var showSettingsButton: Bool = false

    // MARK: — Convenience constructors

    static func cameraPermissionDenied() -> AppAlert {
        AppAlert(
            title: "Camera Access Required",
            message: "CardScan needs camera access to photograph business cards. Please enable it in Settings.",
            showSettingsButton: true
        )
    }

    static func contactsPermissionDenied() -> AppAlert {
        AppAlert(
            title: "Contacts Access Required",
            message: "CardScan needs Contacts access to save this card to your address book. Please enable it in Settings.",
            showSettingsButton: true
        )
    }

    static func ocrFailed(_ detail: String = "") -> AppAlert {
        AppAlert(
            title: "Scan Failed",
            message: detail.isEmpty
                ? "Could not read text from the image. Try better lighting or a clearer photo."
                : "OCR error: \(detail)"
        )
    }

    static func saveFailed(_ detail: String) -> AppAlert {
        AppAlert(
            title: "Save Failed",
            message: detail
        )
    }

    static func noTextDetected() -> AppAlert {
        AppAlert(
            title: "No Text Found",
            message: "CardScan couldn't detect any text. Make sure the card is well-lit and in focus."
        )
    }
}
