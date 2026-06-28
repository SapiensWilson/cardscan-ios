import SwiftUI

/// Surface container that mirrors the web `.review-card` style.
/// Wrap any content in this for the standard card look.
struct CardScanCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .background(Color.csSurface)
            .clipShape(RoundedRectangle(cornerRadius: Radius.xl))
            .overlay {
                RoundedRectangle(cornerRadius: Radius.xl)
                    .strokeBorder(Color.csDivider, lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.07), radius: 2, y: 1)
    }
}

#Preview {
    CardScanCard {
        VStack(alignment: .leading, spacing: Spacing.s4) {
            Text("Extracted Contact Info")
                .font(.csBaseSB)
            Text("Jane Smith · Acme Corp")
                .font(.csSM)
                .foregroundStyle(Color.csTextMuted)
        }
        .padding(Spacing.s6)
    }
    .padding(Spacing.s6)
    .background(Color.csBg)
}
