import SwiftUI

@main
struct CardScanApp: App {
    @StateObject private var appState    = AppState()
    @StateObject private var historyStore = HistoryStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(historyStore)
        }
    }
}
