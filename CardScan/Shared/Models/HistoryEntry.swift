import Foundation

struct HistoryEntry: Codable, Identifiable {
    let id: UUID
    let scannedAt: Date
    var fields: ContactFields
    /// JPEG thumbnail data for the scanned card.
    var thumbnailData: Data?

    init(fields: ContactFields, thumbnailData: Data? = nil) {
        self.id            = UUID()
        self.scannedAt     = Date()
        self.fields        = fields
        self.thumbnailData = thumbnailData
    }
}
