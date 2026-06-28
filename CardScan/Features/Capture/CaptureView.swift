import SwiftUI
import PhotosUI

/// Step 1 — Capture screen. Upload from library or use camera.
/// Phase 2 will wire camera + image preprocessing here.
struct CaptureView: View {
    @EnvironmentObject private var appState: AppState
    @State private var photoItem: PhotosPickerItem? = nil
    @State private var showCamera = false

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.s10) {
                StepIndicator(current: .capture)
                    .padding(.top, Spacing.s4)

                uploadZone
            }
            .padding(.horizontal, Spacing.s6)
            .padding(.bottom, Spacing.s12)
        }
        .background(Color.csBg)
        .withToast()
        // Phase 2: .fullScreenCover(isPresented: $showCamera) { CameraView() }
    }

    // MARK: — Upload zone
    private var uploadZone: some View {
        CardScanCard {
            VStack(spacing: Spacing.s6) {
                // Icon
                RoundedRectangle(cornerRadius: Radius.lg)
                    .fill(Color.csSurfaceOffset)
                    .frame(width: 64, height: 64)
                    .overlay {
                        Image(systemName: "creditcard")
                            .font(.system(size: 28, weight: .light))
                            .foregroundStyle(Color.csTextMuted)
                    }

                // Headline
                VStack(spacing: Spacing.s2) {
                    Text("Scan a Business Card")
                        .font(.csDisplay(size: 26))
                        .foregroundStyle(Color.csText)
                        .multilineTextAlignment(.center)
                    Text("Choose a photo or use your camera")
                        .font(.csSM)
                        .foregroundStyle(Color.csTextMuted)
                        .multilineTextAlignment(.center)
                }

                // Action buttons
                HStack(spacing: Spacing.s3) {
                    PhotosPicker(
                        selection: $photoItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Label("Upload Image", systemImage: "arrow.up.doc")
                    }
                    .buttonStyle(.csPrimary)
                    .onChange(of: photoItem) { _, newItem in
                        handlePickedPhoto(newItem)
                    }

                    Button {
                        showCamera = true
                    } label: {
                        Label("Camera", systemImage: "camera")
                    }
                    .buttonStyle(.csSecondary)
                }

                privacyBadge
            }
            .padding(Spacing.s8)
        }
    }

    // MARK: — Privacy badge
    private var privacyBadge: some View {
        HStack(spacing: Spacing.s2) {
            Image(systemName: "lock.shield")
                .font(.system(size: 11, weight: .semibold))
            Text("100% on-device — nothing leaves your phone")
                .font(.csXS)
                .fontWeight(.semibold)
        }
        .foregroundStyle(Color.csSuccess)
        .padding(.vertical, Spacing.s1)
        .padding(.horizontal, Spacing.s3)
        .background(Color.csSuccessHighlight)
        .clipShape(Capsule())
    }

    // MARK: — Photo handling (stub — Phase 3 wires OCR)
    private func handlePickedPhoto(_ item: PhotosPickerItem?) {
        guard let item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    appState.capturedImage = image
                    // TODO Phase 3: kick off ImagePreprocessor + OCREngine
                    appState.showToast("Image loaded — OCR coming in Phase 3!")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        CaptureView()
    }
    .environmentObject(AppState())
}
