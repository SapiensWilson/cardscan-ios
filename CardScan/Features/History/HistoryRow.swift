import SwiftUI

/// A single row in the HistoryDrawer list.
struct HistoryRow: View {
    let entry: HistoryEntry

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        HStack(spacing: Spacing.s4) {
            // Thumbnail or placeholder
            Group {
                if let data = entry.thumbnailData, let img = UIImage(data: data) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color.csSurfaceOffset
                        .overlay {
                            Image(systemName: "creditcard")
                                .font(.system(size: 18, weight: .light))
                                .foregroundStyle(Color.csTextFaint)
                        }
                }
            }
            .frame(width: 64, height: 40)
            .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
            .overlay {
                RoundedRectangle(cornerRadius: Radius.sm)
                    .strokeBorder(Color.csDivider, lineWidth: 1)
            }

            // Text
            VStack(alignment: .leading, spacing: Spacing.s1) {
                Text(entry.fields.name.isEmpty ? "(unnamed)" : entry.fields.name)
                    .font(.csSMSB)
                    .foregroundStyle(Color.csText)
                    .lineLimit(1)

                let sub = [entry.fields.title, entry.fields.company]
                    .filter { !$0.isEmpty }.joined(separator: " · ")
                if !sub.isEmpty {
                    Text(sub)
                        .font(.csXS)
                        .foregroundStyle(Color.csTextMuted)
                        .lineLimit(1)
                }

                Text(Self.dateFormatter.string(from: entry.scannedAt))
                    .font(.csXS)
                    .foregroundStyle(Color.csTextFaint)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.csTextFaint)
        }
        .padding(.vertical, Spacing.s2)
    }
}
