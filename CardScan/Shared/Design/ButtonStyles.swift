import SwiftUI

// MARK: — Primary Button
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.csSMSB)
            .foregroundStyle(.white)
            .padding(.vertical, Spacing.s3)
            .padding(.horizontal, Spacing.s5)
            .background(configuration.isPressed ? Color.csGreenHover : Color.csGreen)
            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: — Success Button
struct SuccessButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.csSMSB)
            .foregroundStyle(.white)
            .padding(.vertical, Spacing.s3)
            .padding(.horizontal, Spacing.s5)
            .background(configuration.isPressed ? Color.csSuccessHover : Color.csSuccess)
            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: — Secondary Button
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.csSMSB)
            .foregroundStyle(Color.csText)
            .padding(.vertical, Spacing.s3)
            .padding(.horizontal, Spacing.s5)
            .background(configuration.isPressed ? Color.csSurfaceDynamic : Color.csSurfaceOffset)
            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
            .overlay {
                RoundedRectangle(cornerRadius: Radius.md)
                    .strokeBorder(Color.csBorder, lineWidth: 1)
            }
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: — Ghost Button
struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.csSMSB)
            .foregroundStyle(configuration.isPressed ? Color.csText : Color.csTextMuted)
            .padding(.vertical, Spacing.s3)
            .padding(.horizontal, Spacing.s4)
            .background(configuration.isPressed ? Color.csSurfaceOffset : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: — Convenience extensions
extension ButtonStyle where Self == PrimaryButtonStyle {
    static var csPrimary: PrimaryButtonStyle { PrimaryButtonStyle() }
}
extension ButtonStyle where Self == SuccessButtonStyle {
    static var csSuccess: SuccessButtonStyle { SuccessButtonStyle() }
}
extension ButtonStyle where Self == SecondaryButtonStyle {
    static var csSecondary: SecondaryButtonStyle { SecondaryButtonStyle() }
}
extension ButtonStyle where Self == GhostButtonStyle {
    static var csGhost: GhostButtonStyle { GhostButtonStyle() }
}
