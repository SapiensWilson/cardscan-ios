import SwiftUI
import Contacts

struct ExportView: View {
    @EnvironmentObject private var appState:     AppState
    @EnvironmentObject private var historyStore: HistoryStore
    @EnvironmentObject private var proStore:     ProStore

    @State private var vcfURL: URL?         = nil
    @State private var isSavingContact      = false
    @State private var savedToHistory       = false
    @State private var showContactsPaywall  = false
    @State private var showVcfPaywall       = false

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
        .sheet(isPresented: $showContactsPaywall) {
            PaywallView(triggerFeature: .saveContacts).environmentObject(proStore)
        }
        .sheet(isPresented: $showVcfPaywall) {
            PaywallView(triggerFeature: .exportVcf).environmentObject(proStore)
        }
    }

    // MARK: — Export actions card
    private var exportActionsCard: some View {
        CardScanCard {
            VStack(spacing: 0) {
                HStack {
                    Text("Export Contact")
                        .font(.csBaseSB).foregroundStyle(Color.csText)
                    Spacer()
                    if !proStore.isPro {
                        Text("PRO")
                            .font(.system(size: 9, weight: .bold))
                            .tracking(0.5)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Color.csGreen)
                            .clipShape(Capsule())
                    }
                }
                .padding(Spacing.s5).padding(.horizontal, Spacing.s1)

                Divider().background(Color.csDivider)

                VStack(spacing: Spacing.s4) {
                    // Save to Contacts — Pro gated
                    Button {
                        if proStore.isPro { saveToContacts() }
                        else { Haptics.light(); showContactsPaywall = true }
                    } label: {
                        HStack {
                            if isSavingContact {
                                ProgressView().tint(.white).scaleEffect(0.8)
                                    .accessibilityLabel("Saving")
                            } else {
                                Image(systemName: proStore.isPro ? "person.crop.circle.badge.plus" : "lock.fill")
                                    .accessibilityHidden(true)
                            }
                            Text(isSavingContact ? "Saving…" : "Save to Contacts")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.csPrimary)
                    .disabled(isSavingContact)
                    .accessibilityLabel(proStore.isPro ? "Save to Contacts" : "Save to Contacts — Pro feature")
                    .accessibilityHint(proStore.isPro ? "Adds to your iOS address book" : "Tap to unlock with CardScan Pro")

                    // Share .vcf — Pro gated
                    Group {
                        if proStore.isPro, let url = vcfURL {
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
                            .simultaneousGesture(TapGesture().onEnded {
                                recordHistory()
                                Haptics.success()
                                appState.showToast("vCard exported — saved to history ✓")
                            })
                        } else {
                            Button {
                                Haptics.light()
                                showVcfPaywall = true
                            } label: {
                                HStack {
                                    Image(systemName: "lock.fill").accessibilityHidden(true)
                                    Text("Share / Download .vcf")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.csSecondary)
                        }
                    }
                    .accessibilityLabel(proStore.isPro ? "Share vCard file" : "Share vCard — Pro feature")

                    // Copy as text — FREE for everyone
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
                    .accessibilityHint("Free feature — copies all fields to clipboard")

                    // Tip / upsell
                    if !proStore.isPro {
                        Button {
                            Haptics.light()
                            showContactsPaywall = true
                        } label: {
                            HStack(alignment: .top, spacing: Spacing.s2) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.csGreen)
                                    .accessibilityHidden(true)
                                Text("Unlock Save to Contacts and .vcf export with CardScan Pro — $9.99, one-time.")
                                    .font(.csXS)
                                    .foregroundStyle(Color.csTextMuted)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color.csTextFaint)
                            }
                        }
                        .padding(Spacing.s3)
                        .background(Color.csGreenHighlight)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                    }
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
            } label: { Label("Edit Fields", systemImage: "chevron.left") }
            .buttonStyle(.csGhost)
            .accessibilityLabel("Back to edit fields")

            Button {
                Haptics.light()
                appState.reset()
            } label: { Label("Scan Another", systemImage: "arrow.counterclockwise") }
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
        historyStore.add(fields: appState.contact, thumbnail: appState.processedImage ?? appState.capturedImage)
    }
}

#Preview {
    ExportView()
        .environmentObject({ let s = AppState(); s.contact.name = "Jane Smith"; s.step = .export; return s }())
        .environmentObject(HistoryStore())
        .environmentObject(ProStore())
}
