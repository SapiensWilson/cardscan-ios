import SwiftUI

/// Step shown while ImagePreprocessor + OCREngine are running.
/// AppState.processingProgress (0.0–1.0) drives the progress bar.
struct ProcessingView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(spacing: Spacing.s10) {
            StepIndicator(current: .review)
                .padding(.top, Spacing.s4)

            CardScanCard {
                VStack(spacing: Spacing.s6) {
                    // Spinner
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(1.4)
                        .tint(Color.csGreen)

                    // Status text
                    VStack(spacing: Spacing.s2) {
                        Text(appState.processingStatus)
                            .font(.csBaseSB)
                            .foregroundStyle(Color.csText)
                            .multilineTextAlignment(.center)
                            .animation(.default, value: appState.processingStatus)

                        Text("All processing happens on your device.\nNothing leaves your phone.")
                            .font(.csSM)
                            .foregroundStyle(Color.csTextMuted)
                            .multilineTextAlignment(.center)
                    }

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.csSurfaceOffset)
                                .frame(height: 4)
                            Capsule()
                                .fill(Color.csGreen)
                                .frame(width: geo.size.width * appState.processingProgress, height: 4)
                                .animation(.easeInOut(duration: 0.3), value: appState.processingProgress)
                        }
                    }
                    .frame(height: 4)
                }
                .padding(Spacing.s10)
            }
        }
        .padding(.horizontal, Spacing.s6)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.csBg)
    }
}

#Preview {
    ProcessingView()
        .environmentObject({
            let s = AppState()
            s.processingStatus   = "Running OCR on your card…"
            s.processingProgress = 0.6
            return s
        }())
}
