import SwiftUI

@main
struct CardScanApp: App {
    @StateObject private var appState     = AppState()
    @StateObject private var historyStore = HistoryStore()
    @StateObject private var settings     = SettingsStore()
    @StateObject private var proStore     = ProStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(historyStore)
                .environmentObject(settings)
                .environmentObject(proStore)
        }
    }
}
