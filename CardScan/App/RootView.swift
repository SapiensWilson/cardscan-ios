import SwiftUI

/// Top-level navigator. Drives the 3-step Capture → Review → Export flow.
struct RootView: View {
    @EnvironmentObject private var appState: AppState

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
                }
        }
        .tint(Color.csGreen)
    }
}

#Preview {
    RootView()
        .environmentObject(AppState())
}
