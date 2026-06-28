import SwiftUI
import AVFoundation
import Contacts

struct SettingsView: View {
    @EnvironmentObject private var settings:      SettingsStore
    @EnvironmentObject private var historyStore:  HistoryStore
    @EnvironmentObject private var appState:      AppState
    @Environment(\.dismiss) private var dismiss

    @State private var cameraStatus:   AVAuthorizationStatus = .notDetermined
    @State private var contactsStatus: CNAuthorizationStatus = .notDetermined
    @State private var showClearConfirm = false

    var body: some View {
        NavigationStack {
            List {
                appearanceSection
                exportSection
                historySection
                privacySection
                permissionsSection
                aboutSection
            }
            .listStyle(.insetGrouped)
            .background(Color.csBg)
            .scrollContentBackground(.hidden)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        Haptics.light()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.csGreen)
                }
            }
        }
        .onAppear { refreshPermissionStatus() }
    }

    // MARK: — Appearance
    private var appearanceSection: some View {
        Section {
            Picker("Appearance", selection: $settings.appearanceMode) {
                ForEach(SettingsStore.AppearanceMode.allCases) { mode in
                    Text(mode.label).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .listRowBackground(Color.csSurface)
            .accessibilityLabel("Appearance mode")

            Toggle(isOn: $settings.hapticsEnabled) {
                Label("Haptic Feedback", systemImage: "hand.tap")
            }
            .tint(Color.csGreen)
            .listRowBackground(Color.csSurface)
            .onChange(of: settings.hapticsEnabled) { _, on in
                if on { Haptics.light() }
            }
        } header: {
            Text("APPEARANCE & FEEL")
        }
    }

    // MARK: — Export
    private var exportSection: some View {
        Section {
            Picker(selection: $settings.defaultExportAction) {
                ForEach(SettingsStore.DefaultExportAction.allCases) { action in
                    Label(action.label, systemImage: action.icon).tag(action)
                }
            } label: {
                Label("Default Export Action", systemImage: "square.and.arrow.up")
            }
            .listRowBackground(Color.csSurface)

            Toggle(isOn: $settings.showRawOCRByDefault) {
                Label("Show Raw OCR by Default", systemImage: "doc.plaintext")
            }
            .tint(Color.csGreen)
            .listRowBackground(Color.csSurface)
        } header: {
            Text("EXPORT")
        } footer: {
            Text("When set to \u201cAlways ask\u201d the Export screen shows all three options.")
        }
    }

    // MARK: — History
    private var historySection: some View {
        Section {
            Toggle(isOn: $settings.autoSaveToHistory) {
                Label("Auto-save to History", systemImage: "clock.arrow.circlepath")
            }
            .tint(Color.csGreen)
            .listRowBackground(Color.csSurface)

            Picker(selection: $settings.historyLimit) {
                ForEach(SettingsStore.HistoryLimit.allCases) { limit in
                    Text(limit.label).tag(limit)
                }
            } label: {
                Label("Keep Up To", systemImage: "tray.full")
            }
            .listRowBackground(Color.csSurface)

            HStack {
                Label("Scans Saved", systemImage: "number")
                Spacer()
                Text("\(historyStore.entries.count)")
                    .foregroundStyle(Color.csTextMuted)
            }
            .listRowBackground(Color.csSurface)

            Button(role: .destructive) {
                showClearConfirm = true
            } label: {
                Label("Clear Scan History", systemImage: "trash")
                    .foregroundStyle(.red)
            }
            .listRowBackground(Color.csSurface)
            .disabled(historyStore.entries.isEmpty)
            .confirmationDialog(
                "Clear all \(historyStore.entries.count) saved scans?",
                isPresented: $showClearConfirm,
                titleVisibility: .visible
            ) {
                Button("Clear All", role: .destructive) {
                    Haptics.heavy()
                    historyStore.clearAll()
                }
                Button("Cancel", role: .cancel) {}
            }
        } header: {
            Text("HISTORY")
        }
    }

    // MARK: — Privacy
    private var privacySection: some View {
        Section {
            infoRow(
                icon: "lock.shield",
                title: "On-Device Processing",
                detail: "All OCR and parsing happens entirely on your device. No images or contact data are ever sent to a server."
            )
            infoRow(
                icon: "iphone",
                title: "Local Storage Only",
                detail: "Scan history is stored in UserDefaults on this device. It is not synced to iCloud or any external service."
            )
        } header: {
            Text("PRIVACY")
        }
    }

    // MARK: — Permissions
    private var permissionsSection: some View {
        Section {
            permissionRow(
                icon:   "camera",
                title:  "Camera",
                status: cameraStatusLabel
            )
            permissionRow(
                icon:   "person.crop.circle",
                title:  "Contacts",
                status: contactsStatusLabel
            )
            Button {
                CameraPermission.openSettings()
            } label: {
                Label("Manage Permissions in Settings", systemImage: "arrow.up.right")
                    .foregroundStyle(Color.csGreen)
            }
            .listRowBackground(Color.csSurface)
        } header: {
            Text("PERMISSIONS")
        } footer: {
            Text("Tap above to open iOS Settings and review or change CardScan’s access.")
        }
    }

    // MARK: — About
    private var aboutSection: some View {
        Section {
            HStack {
                Label("Version", systemImage: "info.circle")
                Spacer()
                Text(appVersion).foregroundStyle(Color.csTextMuted)
            }
            .listRowBackground(Color.csSurface)

            HStack {
                Label("Build", systemImage: "hammer")
                Spacer()
                Text(buildNumber).foregroundStyle(Color.csTextMuted)
            }
            .listRowBackground(Color.csSurface)

            Link(destination: URL(string: "https://github.com/SapiensWilson/cardscan-ios")!) {
                Label("Source Code on GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                    .foregroundStyle(Color.csGreen)
            }
            .listRowBackground(Color.csSurface)

        } header: {
            Text("ABOUT")
        } footer: {
            openSourceNotice
        }
    }

    // MARK: — Helpers
    @ViewBuilder
    private func infoRow(icon: String, title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s2) {
            Label(title, systemImage: icon)
                .font(.csSM).fontWeight(.medium)
                .foregroundStyle(Color.csText)
            Text(detail)
                .font(.csXS)
                .foregroundStyle(Color.csTextMuted)
        }
        .padding(.vertical, Spacing.s2)
        .listRowBackground(Color.csSurface)
    }

    @ViewBuilder
    private func permissionRow(icon: String, title: String, status: String) -> some View {
        HStack {
            Label(title, systemImage: icon)
            Spacer()
            Text(status)
                .font(.csXS)
                .foregroundStyle(statusColor(status))
        }
        .listRowBackground(Color.csSurface)
    }

    private func statusColor(_ status: String) -> Color {
        switch status {
        case "Allowed":  return Color.csSuccess
        case "Denied":   return .red
        default:         return Color.csTextMuted
        }
    }

    private var cameraStatusLabel: String {
        switch cameraStatus {
        case .authorized:    return "Allowed"
        case .denied:        return "Denied"
        case .restricted:    return "Restricted"
        case .notDetermined: return "Not set"
        @unknown default:    return "Unknown"
        }
    }

    private var contactsStatusLabel: String {
        switch contactsStatus {
        case .authorized:    return "Allowed"
        case .denied:        return "Denied"
        case .restricted:    return "Restricted"
        case .notDetermined: return "Not set"
        @unknown default:    return "Unknown"
        }
    }

    private func refreshPermissionStatus() {
        cameraStatus   = AVCaptureDevice.authorizationStatus(for: .video)
        contactsStatus = CNContactStore.authorizationStatus(for: .contacts)
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
    }

    private var openSourceNotice: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Open-source libraries used:")
            Text("• Apple Vision (OCR) — Apple Inc.")
            Text("• Apple Contacts — Apple Inc.")
            Text("• Apple AVFoundation — Apple Inc.")
            Text("• SwiftUI — Apple Inc.")
            Text("All system frameworks. No third-party dependencies.")
                .padding(.top, 2)
        }
        .font(.system(size: 11))
        .foregroundStyle(Color.csTextFaint)
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsStore())
        .environmentObject(HistoryStore())
        .environmentObject(AppState())
}
