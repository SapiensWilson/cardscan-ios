import SwiftUI
import Contacts

/// Step 3 — Export screen.
/// Mirrors the web app's panel-export.
struct ExportView: View {
    @EnvironmentObject private var appState: AppState

    /// Temp file URL for ShareLink VCF export.
    @State private var vcfURL: URL? = nil
    @State private var isSavingContact = false

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.s6) {
                StepIndicator(current: .export)
                    .padding(.top, Spacing.s4)

                // vCard preview card (teal gradient)
                VCardPreviewCard(fields: appState.contact)

                // Export actions card
                exportActionsCard

                // Bottom buttons
                bottomButtons
            }
            .padding(.horizontal, Spacing.s6)
            .padding(.bottom, Spacing.s12)
        }
        .background(Color.csBg)
        .withToast()
        .onAppear { prepareVCF() }
    }

    // MARK: — Export actions card
    private var exportActionsCard: some View {
        CardScanCard {
            VStack(spacing: 0) {
                HStack {
                    Text("Export Contact")
                        .font(.csBaseSB)
                        .foregroundStyle(Color.csText)
                    Spacer()
                }
                .padding(Spacing.s5)
                .padding(.horizontal, Spacing.s1)

                Divider().background(Color.csDivider)

                VStack(spacing: Spacing.s4) {
                    // Save to Contacts (native)
                    Button {
                        saveToContacts()
                    } label: {
                        HStack {
                            if isSavingContact {
                                ProgressView().tint(.white).scaleEffect(0.8)
                            } else {
                                Image(systemName: "person.crop.circle.badge.plus")
                            }
                            Text(isSavingContact ? "Saving…" : "Save to Contacts")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.csPrimary)
                    .disabled(isSavingContact)

                    // Download .vcf via ShareSheet
                    if let url = vcfURL {
                        ShareLink(item: url, preview: SharePreview(appState.contact.name.isEmpty ? "contact.vcf" : VCardBuilder.filename(for: appState.contact))) {
                            HStack {
                                Image(systemName: "arrow.down.doc")
                                Text("Share / Download .vcf")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.csSecondary)
                    }

                    // Copy as plain text
                    Button {
                        copyAsText()
                    } label: {
                        HStack {
                            Image(systemName: "doc.on.doc")
                            Text("Copy as Text")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.csSecondary)

                    // Tip
                    HStack(alignment: .top, spacing: Spacing.s2) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.csGreen)
                        Text("\"Save to Contacts\" adds directly to your address book. Use \"Share .vcf\" to send to another device or app.")
                            .font(.csXS)
                            .foregroundStyle(Color.csTextMuted)
                    }
                    .padding(Spacing.s3)
                    .background(Color.csSurface)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                    .overlay {
                        RoundedRectangle(cornerRadius: Radius.md)
                            .strokeBorder(Color.csDivider, lineWidth: 1)
                    }
                }
                .padding(Spacing.s5)
            }
        }
    }

    // MARK: — Bottom buttons
    private var bottomButtons: some View {
        HStack(spacing: Spacing.s3) {
            Button {
                appState.step = .review
            } label: {
                Label("Edit Fields", systemImage: "chevron.left")
            }
            .buttonStyle(.csGhost)

            Button {
                appState.reset()
            } label: {
                Label("Scan Another", systemImage: "arrow.counterclockwise")
            }
            .buttonStyle(.csGhost)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: — Actions
    private func prepareVCF() {
        guard let data = VCardBuilder.build(from: appState.contact) else { return }
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(VCardBuilder.filename(for: appState.contact))
        try? data.write(to: url)
        vcfURL = url
    }

    private func saveToContacts() {
        isSavingContact = true
        Task {
            let result = await ContactSaver.save(fields: appState.contact)
            await MainActor.run {
                isSavingContact = false
                switch result {
                case .saved:
                    appState.showToast("Saved to Contacts ✓")
                case .permissionDenied:
                    appState.showToast("Contacts permission denied")
                case .failed(let err):
                    appState.showToast("Save failed: \(err.localizedDescription)")
                }
            }
        }
    }

    private func copyAsText() {
        UIPasteboard.general.string = appState.contact.plainText
        appState.showToast("Copied to clipboard ✓")
    }
}

#Preview {
    NavigationStack {
        ExportView()
    }
    .environmentObject({
        let s = AppState()
        s.contact.name    = "Jane Smith"
        s.contact.title   = "Director of Engineering"
        s.contact.company = "Acme Corp"
        s.contact.phone   = "+1 (555) 012-3456"
        s.contact.email   = "jane@acme.com"
        s.contact.website = "https://acme.com"
        s.step = .export
        return s
    }())
}
