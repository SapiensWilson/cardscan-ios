import SwiftUI

/// The teal gradient contact preview card shown at the top of ExportView.
/// Mirrors the web app's .vcard-preview component.
struct VCardPreviewCard: View {
    let fields: ContactFields

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Decorative circle (matches web ::before pseudo-element)
            Circle()
                .fill(.white.opacity(0.06))
                .frame(width: 160, height: 160)
                .offset(x: 40, y: -40)

            VStack(alignment: .leading, spacing: 0) {
                // Name
                Text(fields.name.isEmpty ? "—" : fields.name)
                    .font(.csDisplay(size: 28))
                    .foregroundStyle(.white)
                    .padding(.bottom, Spacing.s1)

                // Title · Company
                let subtitle = [fields.title, fields.company]
                    .filter { !$0.isEmpty }.joined(separator: " · ")
                Text(subtitle.isEmpty ? "—" : subtitle)
                    .font(.csSM)
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.bottom, Spacing.s6)

                // Contact fields with icons
                VStack(alignment: .leading, spacing: Spacing.s3) {
                    if !fields.phone.isEmpty   { row(icon: "phone",    text: fields.phone) }
                    if !fields.phone2.isEmpty  { row(icon: "phone",    text: fields.phone2) }
                    if !fields.email.isEmpty   { row(icon: "envelope", text: fields.email) }
                    if !fields.website.isEmpty { row(icon: "globe",    text: fields.website.replacingOccurrences(of: "https://", with: "")) }
                    if !fields.address.isEmpty { row(icon: "mappin",   text: fields.address) }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(Spacing.s8)
        .background(
            LinearGradient(
                colors: [Color.csGreen, Color.csGreenHover],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: Radius.xl))
        .shadow(color: .black.opacity(0.18), radius: 20, y: 12)
    }

    @ViewBuilder
    private func row(icon: String, text: String) -> some View {
        HStack(spacing: Spacing.s3) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.7))
                .frame(width: 16)
            Text(text)
                .font(.csSM)
                .foregroundStyle(.white.opacity(0.9))
                .lineLimit(1)
        }
    }
}

#Preview {
    VCardPreviewCard(fields: {
        var f = ContactFields()
        f.name    = "Jane Smith"
        f.title   = "Director of Engineering"
        f.company = "Acme Corp"
        f.phone   = "+1 (555) 012-3456"
        f.email   = "jane@acme.com"
        f.website = "https://acme.com"
        return f
    }())
    .padding()
    .background(Color.csBg)
}
