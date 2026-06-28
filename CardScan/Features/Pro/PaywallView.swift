import SwiftUI
import StoreKit

/// Full-screen paywall shown when a free user taps a Pro-gated feature.
struct PaywallView: View {
    @EnvironmentObject private var proStore: ProStore
    @Environment(\.dismiss) private var dismiss

    /// The feature that triggered this paywall (shown in the header).
    var triggerFeature: ProFeature = .general

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Hero
                    heroSection

                    // Feature list
                    featureList
                        .padding(.top, Spacing.s8)

                    // Price + CTA
                    purchaseSection
                        .padding(.top, Spacing.s8)

                    // Restore + legal
                    footerSection
                        .padding(.top, Spacing.s4)
                }
                .padding(.horizontal, Spacing.s6)
                .padding(.bottom, Spacing.s12)
            }
            .background(Color.csBg)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Not now") { dismiss() }
                        .font(.csSM)
                        .foregroundStyle(Color.csTextMuted)
                }
            }
        }
        .interactiveDismissDisabled(proStore.isLoading)
        .onChange(of: proStore.isPro) { _, isPro in
            if isPro {
                Haptics.success()
                dismiss()
            }
        }
    }

    // MARK: — Hero
    private var heroSection: some View {
        VStack(spacing: Spacing.s4) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: Radius.xl)
                    .fill(
                        LinearGradient(
                            colors: [Color.csGreen, Color.csGreenHover],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                Image(systemName: "creditcard.and.123")
                    .font(.system(size: 36, weight: .light))
                    .foregroundStyle(.white)
            }
            .padding(.top, Spacing.s8)
            .accessibilityHidden(true)

            VStack(spacing: Spacing.s2) {
                Text("CardScan Pro")
                    .font(.csDisplay(size: 32))
                    .foregroundStyle(Color.csText)

                Text(triggerFeature.upsellMessage)
                    .font(.csSM)
                    .foregroundStyle(Color.csTextMuted)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: — Feature list
    private var featureList: some View {
        CardScanCard {
            VStack(spacing: 0) {
                ForEach(Array(ProFeature.allBenefits.enumerated()), id: \.offset) { idx, benefit in
                    HStack(spacing: Spacing.s4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(Color.csGreen)
                            .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(benefit.title)
                                .font(.csSMSB)
                                .foregroundStyle(Color.csText)
                            Text(benefit.detail)
                                .font(.csXS)
                                .foregroundStyle(Color.csTextMuted)
                        }
                        Spacer()
                    }
                    .padding(.vertical, Spacing.s4)
                    .padding(.horizontal, Spacing.s5)
                    if idx < ProFeature.allBenefits.count - 1 {
                        Divider().background(Color.csDivider).padding(.leading, 56)
                    }
                }
            }
        }
    }

    // MARK: — Purchase section
    private var purchaseSection: some View {
        VStack(spacing: Spacing.s4) {
            // Price badge
            HStack(spacing: Spacing.s2) {
                if let product = proStore.product {
                    Text(product.displayPrice)
                        .font(.csDisplay(size: 36))
                        .foregroundStyle(Color.csText)
                    Text("one-time")
                        .font(.csSM)
                        .foregroundStyle(Color.csTextMuted)
                        .padding(.top, 8)
                } else {
                    ProgressView().tint(Color.csGreen)
                }
            }

            Text("Pay once. Yours forever.")
                .font(.csXS)
                .foregroundStyle(Color.csTextMuted)

            // Buy button
            Button {
                Task { await proStore.purchase() }
            } label: {
                Group {
                    if proStore.isLoading {
                        HStack(spacing: Spacing.s3) {
                            ProgressView().tint(.white).scaleEffect(0.85)
                            Text("Processing…")
                        }
                    } else {
                        Text(proStore.product != nil
                            ? "Unlock CardScan Pro — \(proStore.product!.displayPrice)"
                            : "Unlock CardScan Pro"
                        )
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.csPrimary)
            .disabled(proStore.isLoading || proStore.product == nil)
            .accessibilityLabel("Purchase CardScan Pro")
            .accessibilityHint("One-time purchase. No subscription.")

            // Error
            if let err = proStore.purchaseError {
                Text(err)
                    .font(.csXS)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: — Footer
    private var footerSection: some View {
        VStack(spacing: Spacing.s3) {
            Button {
                Task { await proStore.restore() }
            } label: {
                Text("Restore previous purchase")
                    .font(.csXS)
                    .foregroundStyle(Color.csTextMuted)
                    .underline()
            }
            .disabled(proStore.isLoading)

            Text("Payment charged to your Apple ID at confirmation. One-time purchase — no recurring charges.")
                .font(.system(size: 10))
                .foregroundStyle(Color.csTextFaint)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    PaywallView(triggerFeature: .saveContacts)
        .environmentObject(ProStore())
}
