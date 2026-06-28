import SwiftUI
import Combine

/// Persists user preferences to UserDefaults.
final class SettingsStore: ObservableObject {

    // MARK: — Appearance
    enum AppearanceMode: String, CaseIterable, Identifiable {
        case system, light, dark
        var id: String { rawValue }
        var label: String {
            switch self {
            case .system: return "System"
            case .light:  return "Light"
            case .dark:   return "Dark"
            }
        }
        var colorScheme: ColorScheme? {
            switch self {
            case .system: return nil
            case .light:  return .light
            case .dark:   return .dark
            }
        }
    }

    // MARK: — Default export action
    enum DefaultExportAction: String, CaseIterable, Identifiable {
        case ask, saveContacts, shareVcf, copyText
        var id: String { rawValue }
        var label: String {
            switch self {
            case .ask:          return "Always ask"
            case .saveContacts: return "Save to Contacts"
            case .shareVcf:     return "Share .vcf"
            case .copyText:     return "Copy as text"
            }
        }
        var icon: String {
            switch self {
            case .ask:          return "questionmark.circle"
            case .saveContacts: return "person.crop.circle.badge.plus"
            case .shareVcf:     return "arrow.down.doc"
            case .copyText:     return "doc.on.doc"
            }
        }
    }

    // MARK: — History limit
    enum HistoryLimit: Int, CaseIterable, Identifiable {
        case ten = 10, twenty = 20, fifty = 50, hundred = 100
        var id: Int { rawValue }
        var label: String { "\(rawValue) scans" }
    }

    // MARK: — Published preferences
    @Published var appearanceMode: AppearanceMode  = .system {
        didSet { save("appearanceMode", appearanceMode.rawValue) }
    }
    @Published var defaultExportAction: DefaultExportAction = .ask {
        didSet { save("defaultExportAction", defaultExportAction.rawValue) }
    }
    @Published var historyLimit: HistoryLimit = .fifty {
        didSet { save("historyLimit", historyLimit.rawValue) }
    }
    @Published var hapticsEnabled: Bool = true {
        didSet { save("hapticsEnabled", hapticsEnabled) }
    }
    @Published var autoSaveToHistory: Bool = true {
        didSet { save("autoSaveToHistory", autoSaveToHistory) }
    }
    @Published var showRawOCRByDefault: Bool = false {
        didSet { save("showRawOCRByDefault", showRawOCRByDefault) }
    }

    // MARK: — Init
    init() { load() }

    // MARK: — Persistence helpers
    private func load() {
        let d = UserDefaults.standard
        if let v = d.string(forKey: "appearanceMode"),    let m = AppearanceMode(rawValue: v)    { appearanceMode = m }
        if let v = d.string(forKey: "defaultExportAction"), let m = DefaultExportAction(rawValue: v) { defaultExportAction = m }
        if let v = d.object(forKey: "historyLimit") as? Int, let m = HistoryLimit(rawValue: v)  { historyLimit = m }
        if d.object(forKey: "hapticsEnabled")      != nil { hapticsEnabled      = d.bool(forKey: "hapticsEnabled") }
        if d.object(forKey: "autoSaveToHistory")   != nil { autoSaveToHistory   = d.bool(forKey: "autoSaveToHistory") }
        if d.object(forKey: "showRawOCRByDefault") != nil { showRawOCRByDefault = d.bool(forKey: "showRawOCRByDefault") }
    }

    private func save(_ key: String, _ value: String)  { UserDefaults.standard.set(value, forKey: key) }
    private func save(_ key: String, _ value: Int)     { UserDefaults.standard.set(value, forKey: key) }
    private func save(_ key: String, _ value: Bool)    { UserDefaults.standard.set(value, forKey: key) }
}
