import SwiftUI
import Combine

/// Persists scan history to UserDefaults.
/// Free tier: max 5 entries. Pro: up to settingsStore limit (default 50).
final class HistoryStore: ObservableObject {

    private static let key        = "cardscan.history"
    static  let freeLimit         = 5
    static  let proDefaultLimit   = 50

    @Published private(set) var entries: [HistoryEntry] = []

    init() { load() }

    func add(fields: ContactFields, thumbnail: UIImage?, isPro: Bool = false, proLimit: Int = proDefaultLimit) {
        let data  = thumbnail.flatMap { $0.jpegData(compressionQuality: 0.6) }
        let entry = HistoryEntry(fields: fields, thumbnailData: data)
        entries.insert(entry, at: 0)
        let cap = isPro ? proLimit : Self.freeLimit
        if entries.count > cap { entries = Array(entries.prefix(cap)) }
        save()
    }

    func remove(id: UUID)  { entries.removeAll { $0.id == id }; save() }
    func clearAll()        { entries = []; save() }

    private func load() {
        guard let data    = UserDefaults.standard.data(forKey: Self.key),
              let decoded = try? JSONDecoder().decode([HistoryEntry].self, from: data)
        else { return }
        entries = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        UserDefaults.standard.set(data, forKey: Self.key)
    }
}
