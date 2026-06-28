import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState:      AppState
    @EnvironmentObject private var historyStore:  HistoryStore
    @EnvironmentObject private var settings:      SettingsStore
    @State private var showHistory  = false
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            CaptureView()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    // Leading — settings gear
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            Haptics.light()
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                                .font(.system(size: 18))
                                .foregroundStyle(Color.csTextMuted)
                        }
                        .accessibilityLabel("Settings")
                    }

                    // Centre — wordmark
                    ToolbarItem(placement: .principal) {
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: Radius.md)
                                .fill(Color.csGreen)
                                .frame(width: 28, height: 28)
                                .overlay {
                                    Image(systemName: "creditcard")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(.white)
                                }
                                .accessibilityHidden(true)
                            Text("CardScan")
                                .font(.csDisplay(size: 20))
                                .foregroundStyle(Color.csText)
                        }
                        .accessibilityLabel("CardScan")
                    }

                    // Trailing — history clock + badge
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            Haptics.light()
                            showHistory = true
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.system(size: 18))
                                    .foregroundStyle(Color.csTextMuted)
                                if historyStore.entries.count > 0 {
                                    Text("\(min(historyStore.entries.count, 99))")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundStyle(.white)
                                        .padding(3)
                                        .background(Color.csGreen)
                                        .clipShape(Circle())
                                        .offset(x: 8, y: -8)
                                        .accessibilityHidden(true)
                                }
                            }
                        }
                        .accessibilityLabel("Scan history")
                        .accessibilityHint(historyStore.entries.isEmpty
                            ? "No scans yet"
                            : "\(historyStore.entries.count) scan\(historyStore.entries.count == 1 ? "" : "s") saved. Tap to view.")
                    }
                }
        }
        .tint(Color.csGreen)
        // Respect the user's appearance preference
        .preferredColorScheme(settings.appearanceMode.colorScheme)
        // Sheets
        .sheet(isPresented: $showHistory) {
            HistoryDrawer()
                .environmentObject(historyStore)
                .environmentObject(appState)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(settings)
                .environmentObject(historyStore)
                .environmentObject(appState)
                .preferredColorScheme(settings.appearanceMode.colorScheme)
        }
        // Centralised app-wide alert
        .alert(item: $appState.activeAlert) { alert in
            if alert.showSettingsButton {
                return Alert(
                    title: Text(alert.title),
                    message: Text(alert.message),
                    primaryButton: .default(Text("Open Settings")) {
                        CameraPermission.openSettings()
                    },
                    secondaryButton: .cancel()
                )
            } else {
                return Alert(
                    title: Text(alert.title),
                    message: Text(alert.message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AppState())
        .environmentObject(HistoryStore())
        .environmentObject(SettingsStore())
}
