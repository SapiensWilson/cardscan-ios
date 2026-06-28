import SwiftUI

/// Top-level navigator with history toolbar button and badge.
struct RootView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var historyStore: HistoryStore
    @State private var showHistory = false

    var body: some View {
        NavigationStack {
            CaptureView()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
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
                            Text("CardScan")
                                .font(.csDisplay(size: 20))
                                .foregroundStyle(Color.csText)
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
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
                                }
                            }
                        }
                    }
                }
        }
        .tint(Color.csGreen)
        .sheet(isPresented: $showHistory) {
            HistoryDrawer()
                .environmentObject(historyStore)
                .environmentObject(appState)
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AppState())
        .environmentObject(HistoryStore())
}
