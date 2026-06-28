import SwiftUI
import Combine

/// Persists scan history to UserDefaults (max 50 entries, newest first).
/// Injected as an @EnvironmentObject alongside AppState.
final class HistoryStore: ObservableObject {

    private static let key    = "cardscan.history"
    private static let maxLen = 50

    @Published private(set) var entries: [HistoryEntry] = []

    init() { load() }

    // MARK: — Public API

    /// Add a new entry. Call after a successful export.
    func add(fields: ContactFields, thumbnail: UIImage?) {
        let data = thumbnail.flatMap {
            $0.jpegData(compressionQuality: 0.6)
        }
        let entry = HistoryEntry(fields: fields, thumbnailData: data)
        entries.insert(entry, at: 0)
        if entries.count > Self.maxLen { entries = Array(entries.prefix(Self.maxLen)) }
        save()
    }

    /// Remove a single entry by id.
    func remove(id: UUID) {
        entries.removeAll { $0.id == id }
        save()
    }

    /// Wipe all history.
    func clearAll() {
        entries = []
        save()
    }

    // MARK: — Persistence
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: Self.key),
              let decoded = try? JSONDecoder().decode([HistoryEntry].self, from: data)
        else { return }
        entries = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        UserDefaults.standard.set(data, forKey: Self.key)
    }
}
