import SwiftUI

/// Step 2 — Editable contact field review.
/// Mirrors the web app's panel-review.
struct ReviewView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showRaw = false
    @FocusState private var focusedField: ReviewField?

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: Spacing.s6) {
                    StepIndicator(current: .review)
                        .padding(.top, Spacing.s4)

                    // Scanned card thumbnail
                    if let img = appState.processedImage ?? appState.capturedImage {
                        thumbnailView(img)
                    }

                    // Editable form card
                    formCard

                    // Action buttons
                    actionButtons
                }
                .padding(.horizontal, Spacing.s6)
                .padding(.bottom, Spacing.s12)
            }
            .background(Color.csBg)
            .withToast()
            .onChange(of: focusedField) { _, field in
                if let field {
                    withAnimation { proxy.scrollTo(field, anchor: .center) }
                }
            }
        }
    }

    // MARK: — Thumbnail
    private func thumbnailView(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .frame(maxHeight: 180)
            .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            .overlay {
                RoundedRectangle(cornerRadius: Radius.lg)
                    .strokeBorder(Color.csDivider, lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.07), radius: 2, y: 1)
    }

    // MARK: — Form card
    private var formCard: some View {
        CardScanCard {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Extracted Contact Info")
                        .font(.csBaseSB)
                        .foregroundStyle(Color.csText)
                    Spacer()
                    Button(showRaw ? "Hide raw text" : "Show raw text") {
                        withAnimation { showRaw.toggle() }
                    }
                    .font(.csXS)
                    .foregroundStyle(Color.csTextMuted)
                }
                .padding(Spacing.s5)
                .padding(.horizontal, Spacing.s1)

                Divider().background(Color.csDivider)

                // Fields grid
                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: Spacing.s4
                ) {
                    ReviewField.allCases.forEach { field in
                        fieldView(field)
                            .id(field)
                            .gridCellColumns(field.fullWidth ? 2 : 1)
                    }
                }
                .padding(Spacing.s5)

                // Raw OCR panel
                if showRaw {
                    Divider().background(Color.csDivider)
                    rawPanel
                }
            }
        }
    }

    // MARK: — Individual field
    @ViewBuilder
    private func fieldView(_ field: ReviewField) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s2) {
            // Label
            HStack(spacing: Spacing.s2) {
                Image(systemName: field.icon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.csGreen)
                Text(field.label)
                    .font(.csXS)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.csTextMuted)
                    .textCase(.uppercase)
                    .tracking(0.8)
            }

            // Input
            TextField(field.placeholder, text: field.binding(in: appState))
                .font(.csSM)
                .foregroundStyle(Color.csText)
                .padding(.vertical, Spacing.s3)
                .padding(.horizontal, Spacing.s4)
                .background(Color.csSurface2)
                .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                .overlay {
                    RoundedRectangle(cornerRadius: Radius.md)
                        .strokeBorder(focusedField == field ? Color.csGreen : Color.csBorder, lineWidth: 1)
                }
                .keyboardType(field.keyboardType)
                .textContentType(field.textContentType)
                .autocorrectionDisabled(field.noAutoCorrect)
                .focused($focusedField, equals: field)
        }
    }

    // MARK: — Raw OCR panel
    private var rawPanel: some View {
        VStack(alignment: .leading, spacing: Spacing.s2) {
            Text("RAW OCR OUTPUT")
                .font(.csXS)
                .fontWeight(.semibold)
                .foregroundStyle(Color.csTextMuted)
                .tracking(0.8)

            ScrollView {
                Text(appState.rawOCRText.isEmpty ? "(no text detected)" : appState.rawOCRText)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(Color.csTextMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: 140)
            .padding(Spacing.s4)
            .background(Color.csSurfaceOffset)
            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
            .overlay {
                RoundedRectangle(cornerRadius: Radius.md)
                    .strokeBorder(Color.csDivider, lineWidth: 1)
            }
        }
        .padding(Spacing.s5)
    }

    // MARK: — Action buttons
    private var actionButtons: some View {
        HStack(spacing: Spacing.s3) {
            Button {
                appState.step = .export
            } label: {
                Label("Continue to Export", systemImage: "chevron.right")
            }
            .buttonStyle(.csPrimary)

            Button {
                appState.reset()
            } label: {
                Label("Scan Another", systemImage: "arrow.counterclockwise")
            }
            .buttonStyle(.csGhost)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ReviewView()
        .environmentObject({
            let s = AppState()
            s.contact.name    = "Jane Smith"
            s.contact.title   = "Director of Engineering"
            s.contact.company = "Acme Corp"
            s.contact.phone   = "+1 (555) 012-3456"
            s.contact.email   = "jane@acme.com"
            s.contact.website = "https://acme.com"
            s.rawOCRText      = "Jane Smith\nDirector of Engineering\nAcme Corp\njane@acme.com"
            return s
        }())
}
