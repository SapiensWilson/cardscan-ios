import SwiftUI
import Contacts

struct ExportView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var historyStore: HistoryStore

    @State private var vcfURL: URL? = nil
    @State private var isSavingContact = false
    @State private var savedToHistory  = false

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.s6) {
                StepIndicator(current: .export)
                    .padding(.top, Spacing.s4)

                VCardPreviewCard(fields: appState.contact)
                    .accessibilityLabel("Contact card for \(appState.contact.name.isEmpty ? "unnamed contact" : appState.contact.name)")

                exportActionsCard
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
                        .font(.csBaseSB).foregroundStyle(Color.csText)
                    Spacer()
                }
                .padding(Spacing.s5).padding(.horizontal, Spacing.s1)

                Divider().background(Color.csDivider)

                VStack(spacing: Spacing.s4) {
                    // Save to Contacts
                    Button {
                        saveToContacts()
                    } label: {
                        HStack {
                            if isSavingContact {
                                ProgressView().tint(.white).scaleEffect(0.8)
                                    .accessibilityLabel("Saving")
                            } else {
                                Image(systemName: "person.crop.circle.badge.plus")
                                    .accessibilityHidden(true)
                            }
                            Text(isSavingContact ? "Saving…" : "Save to Contacts")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.csPrimary)
                    .disabled(isSavingContact)
                    .accessibilityLabel("Save to Contacts")
                    .accessibilityHint("Adds this contact directly to your iOS address book")

                    // Share .vcf
                    if let url = vcfURL {
                        ShareLink(
                            item: url,
                            preview: SharePreview(appState.contact.name.isEmpty ? "contact.vcf" : VCardBuilder.filename(for: appState.contact))
                        ) {
                            HStack {
                                Image(systemName: "arrow.down.doc").accessibilityHidden(true)
                                Text("Share / Download .vcf")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.csSecondary)
                        .accessibilityLabel("Share vCard file")
                        .accessibilityHint("Opens the share sheet to send or save the .vcf file")
                        .simultaneousGesture(TapGesture().onEnded {
                            recordHistory()
                            Haptics.success()
                            appState.showToast("vCard exported — saved to history ✓")
                        })
                    }

                    // Copy as text
                    Button {
                        copyAsText()
                    } label: {
                        HStack {
                            Image(systemName: "doc.on.doc").accessibilityHidden(true)
                            Text("Copy as Text")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.csSecondary)
                    .accessibilityLabel("Copy contact as plain text")
                    .accessibilityHint("Copies all contact fields to the clipboard")

                    // Tip
                    HStack(alignment: .top, spacing: Spacing.s2) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.csGreen)
                            .accessibilityHidden(true)
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
                    .accessibilityElement(children: .combine)
                }
                .padding(Spacing.s5)
            }
        }
    }

    private var bottomButtons: some View {
        HStack(spacing: Spacing.s3) {
            Button {
                Haptics.light()
                appState.step = .review
            } label: {
                Label("Edit Fields", systemImage: "chevron.left")
            }
            .buttonStyle(.csGhost)
            .accessibilityLabel("Back to edit fields")

            Button {
                Haptics.light()
                appState.reset()
            } label: {
                Label("Scan Another", systemImage: "arrow.counterclockwise")
            }
            .buttonStyle(.csGhost)
            .accessibilityLabel("Scan another card")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: — Helpers
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
                    recordHistory()
                    Haptics.success()
                    appState.showToast("Saved to Contacts — added to history ✓")
                case .permissionDenied:
                    Haptics.error()
                    appState.showAlert(.contactsPermissionDenied())
                case .failed(let err):
                    Haptics.error()
                    appState.showAlert(.saveFailed(err.localizedDescription))
                }
            }
        }
    }

    private func copyAsText() {
        UIPasteboard.general.string = appState.contact.plainText
        recordHistory()
        Haptics.success()
        appState.showToast("Copied to clipboard — saved to history ✓")
    }

    private func recordHistory() {
        guard !savedToHistory else { return }
        savedToHistory = true
        historyStore.add(
            fields:    appState.contact,
            thumbnail: appState.processedImage ?? appState.capturedImage
        )
    }
}

#Preview {
    ExportView()
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
        .environmentObject(HistoryStore())
}
