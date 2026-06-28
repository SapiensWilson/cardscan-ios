import SwiftUI

/// Wraps any view or action behind a Pro check.
/// Free users see the PaywallView; Pro users pass straight through.
struct ProGate<Content: View>: View {
    @EnvironmentObject private var proStore: ProStore
    let feature: ProFeature
    let content: Content
    @State private var showPaywall = false

    init(feature: ProFeature, @ViewBuilder content: () -> Content) {
        self.feature = feature
        self.content = content()
    }

    var body: some View {
        Group {
            if proStore.isPro {
                content
            } else {
                // Render the content but intercept taps
                content
                    .allowsHitTesting(false)
                    .overlay {
                        Button {
                            Haptics.light()
                            showPaywall = true
                        } label: {
                            Color.clear
                        }
                    }
                    .overlay(alignment: .topTrailing) {
                        proLockBadge
                    }
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(triggerFeature: feature)
                .environmentObject(proStore)
        }
    }

    private var proLockBadge: some View {
        HStack(spacing: 3) {
            Image(systemName: "lock.fill")
                .font(.system(size: 8, weight: .bold))
            Text("PRO")
                .font(.system(size: 8, weight: .bold))
                .tracking(0.5)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Color.csGreen)
        .clipShape(Capsule())
        .padding(6)
        .accessibilityLabel("Pro feature")
        .accessibilityHint("Tap to unlock with CardScan Pro")
    }
}

/// Convenience modifier for actions (buttons) rather than views.
extension View {
    /// Gates an action behind Pro. Free users see the paywall instead of the action firing.
    func proGated(
        feature: ProFeature,
        isPro: Bool,
        showPaywall: Binding<Bool>
    ) -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded {
                if !isPro {
                    Haptics.light()
                    showPaywall.wrappedValue = true
                }
            }
        )
    }
}
