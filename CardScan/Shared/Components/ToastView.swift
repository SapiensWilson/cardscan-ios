import SwiftUI

/// Bottom-right toast. Drive via AppState.showToast(_:).
/// Attach with .toastOverlay() modifier on the root view.
struct ToastView: View {
    let message: String

    var body: some View {
        HStack(spacing: Spacing.s2) {
            Image(systemName: "checkmark")
                .font(.system(size: 13, weight: .bold))
            Text(message)
                .font(.csSMSB)
        }
        .foregroundStyle(.white)
        .padding(.vertical, Spacing.s3)
        .padding(.horizontal, Spacing.s5)
        .background(Color.csSuccess)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .shadow(color: .black.opacity(0.18), radius: 16, y: 8)
    }
}

// MARK: — ViewModifier
struct ToastModifier: ViewModifier {
    @EnvironmentObject private var appState: AppState

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if let msg = appState.toastMessage {
                    ToastView(message: msg)
                        .padding(.bottom, Spacing.s6)
                        .padding(.horizontal, Spacing.s6)
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal:   .opacity
                            )
                        )
                        .id(msg) // re-trigger animation on new message
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: appState.toastMessage)
    }
}

extension View {
    /// Attach once on the root view to enable toasts app-wide.
    func withToast() -> some View {
        modifier(ToastModifier())
    }
}

#Preview {
    ToastView(message: "vCard downloaded — saved to history!")
        .padding()
        .background(Color.csBg)
}
