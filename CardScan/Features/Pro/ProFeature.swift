import Foundation

/// All Pro-gated features and the benefit list shown on the paywall.
enum ProFeature {
    case saveContacts
    case exportVcf
    case unlimitedHistory
    case general

    /// Short upsell message shown in the paywall hero for this trigger.
    var upsellMessage: String {
        switch self {
        case .saveContacts:
            return "Save contacts directly to your address book\nwith CardScan Pro."
        case .exportVcf:
            return "Share .vcf files and export contacts\nwith CardScan Pro."
        case .unlimitedHistory:
            return "Keep unlimited scan history\nwith CardScan Pro."
        case .general:
            return "Unlock the full CardScan experience\nwith a one-time upgrade."
        }
    }

    // MARK: — Paywall benefit rows
    struct Benefit {
        let title: String
        let detail: String
    }

    static let allBenefits: [Benefit] = [
        Benefit(
            title: "Unlimited Scan History",
            detail: "Free tier keeps 5 scans. Pro keeps them all."
        ),
        Benefit(
            title: "Save to Contacts",
            detail: "Add scanned cards directly to your iOS address book."
        ),
        Benefit(
            title: "Share & Export .vcf",
            detail: "Send vCard files via AirDrop, Mail, or any app."
        ),
        Benefit(
            title: "Customise Settings",
            detail: "Appearance, default export action, and more."
        ),
        Benefit(
            title: "Pay Once, Keep Forever",
            detail: "No subscription. No recurring charges. Ever."
        ),
    ]
}
