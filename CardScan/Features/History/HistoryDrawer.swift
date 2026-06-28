import SwiftUI

struct HistoryDrawer: View {
    @EnvironmentObject private var historyStore: HistoryStore
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var showClearConfirm = false

    var body: some View {
        NavigationStack {
            Group {
                if historyStore.entries.isEmpty {
                    emptyState
                } else {
                    entryList
                }
            }
            .navigationTitle("Scan History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        Haptics.light()
                        dismiss()
                    }
                    .font(.csSM)
                    .foregroundStyle(Color.csTextMuted)
                    .accessibilityLabel("Close history")
                }
                if !historyStore.entries.isEmpty {
                    ToolbarItem(placement: .destructiveAction) {
                        Button("Clear All") {
                            showClearConfirm = true
                        }
                        .font(.csSM)
                        .foregroundStyle(.red)
                        .accessibilityLabel("Clear all scan history")
                        .accessibilityHint("Permanently deletes all \(historyStore.entries.count) saved scans")
                    }
                }
            }
            .confirmationDialog(
                "Clear all scan history?",
                isPresented: $showClearConfirm,
                titleVisibility: .visible
            ) {
                Button("Clear All", role: .destructive) {
                    Haptics.heavy()
                    historyStore.clearAll()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
        .background(Color.csBg)
    }

    // MARK: — Entry list
    private var entryList: some View {
        List {
            ForEach(historyStore.entries) { entry in
                HistoryRow(entry: entry)
                    .listRowBackground(Color.csSurface)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .accessibilityLabel(rowAccessibilityLabel(entry))
                    .accessibilityHint("Swipe left to delete. Swipe right to export.")
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            Haptics.medium()
                            withAnimation { historyStore.remove(id: entry.id) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading) {
                        ShareLink(
                            item: vcfURL(for: entry),
                            preview: SharePreview(entry.fields.name.isEmpty ? "contact.vcf" : entry.fields.name)
                        ) {
                            Label("Export", systemImage: "square.and.arrow.up")
                        }
                        .tint(Color.csGreen)
                    }
                    .contextMenu {
                        ShareLink(
                            item: vcfURL(for: entry),
                            preview: SharePreview(entry.fields.name.isEmpty ? "contact.vcf" : entry.fields.name)
                        ) {
                            Label("Share .vcf", systemImage: "square.and.arrow.up")
                        }
                        Button(role: .destructive) {
                            Haptics.medium()
                            historyStore.remove(id: entry.id)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.plain)
        .background(Color.csBg)
        .scrollContentBackground(.hidden)
    }

    // MARK: — Empty state
    private var emptyState: some View {
        VStack(spacing: Spacing.s4) {
            Spacer()
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(Color.csTextFaint)
                .accessibilityHidden(true)
            Text("No scans yet")
                .font(.csBaseSB)
                .foregroundStyle(Color.csText)
            Text("Your scan history will appear here\nafter you export a contact.")
                .font(.csSM)
                .foregroundStyle(Color.csTextMuted)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("No scan history yet. Export a contact to save it here.")
    }

    // MARK: — Helpers
    private func rowAccessibilityLabel(_ entry: HistoryEntry) -> String {
        var parts: [String] = []
        if !entry.fields.name.isEmpty    { parts.append(entry.fields.name) }
        if !entry.fields.company.isEmpty { parts.append(entry.fields.company) }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        parts.append("Scanned \(formatter.string(from: entry.scannedAt))")
        return parts.joined(separator: ", ")
    }

    private func vcfURL(for entry: HistoryEntry) -> URL {
        let data = VCardBuilder.build(from: entry.fields) ?? Data()
        let url  = FileManager.default.temporaryDirectory
            .appendingPathComponent(VCardBuilder.filename(for: entry.fields))
        try? data.write(to: url)
        return url
    }
}

#Preview {
    HistoryDrawer()
        .environmentObject({
            let store = HistoryStore()
            var f = ContactFields()
            f.name = "Jane Smith"; f.company = "Acme Corp"; f.email = "jane@acme.com"
            store.add(fields: f, thumbnail: nil)
            return store
        }())
        .environmentObject(AppState())
}
