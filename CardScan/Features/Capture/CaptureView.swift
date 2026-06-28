import SwiftUI
import PhotosUI

/// Step 1 — Capture screen. Upload from library or use camera.
struct CaptureView: View {
    @EnvironmentObject private var appState: AppState
    @State private var photoItem: PhotosPickerItem? = nil
    @State private var showCamera = false

    var body: some View {
        Group {
            switch appState.step {
            case .capture:
                captureContent
            case .processing:
                ProcessingView()
            case .review:
                // Phase 4 will replace this stub
                ReviewStubView()
            case .export:
                // Phase 5
                Text("Export — coming in Phase 5")
                    .foregroundStyle(Color.csTextMuted)
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraView()
                .environmentObject(appState)
        }
        .onChange(of: appState.capturedImage) { _, img in
            guard let img else { return }
            Task { await ScanPipeline.run(image: img, appState: appState) }
        }
    }

    // MARK: — Capture content
    private var captureContent: some View {
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
    }

    // MARK: — Upload zone
    private var uploadZone: some View {
        CardScanCard {
            VStack(spacing: Spacing.s6) {
                RoundedRectangle(cornerRadius: Radius.lg)
                    .fill(Color.csSurfaceOffset)
                    .frame(width: 64, height: 64)
                    .overlay {
                        Image(systemName: "creditcard")
                            .font(.system(size: 28, weight: .light))
                            .foregroundStyle(Color.csTextMuted)
                    }

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

    private func handlePickedPhoto(_ item: PhotosPickerItem?) {
        guard let item else { return }
        Task {
            if let data  = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run { appState.capturedImage = image }
            }
        }
    }
}

/// Temporary stub shown after OCR while Phase 4 (ReviewView) is built.
private struct ReviewStubView: View {
    @EnvironmentObject private var appState: AppState
    var body: some View {
        VStack(spacing: Spacing.s6) {
            StepIndicator(current: .review).padding(.top, Spacing.s4)
            CardScanCard {
                VStack(alignment: .leading, spacing: Spacing.s4) {
                    Text("OCR Complete ✔️").font(.csBaseSB)
                    Text(appState.rawOCRText.isEmpty ? "No text detected" : appState.rawOCRText)
                        .font(.csXS)
                        .foregroundStyle(Color.csTextMuted)
                    Button("Scan Another") { appState.reset() }
                        .buttonStyle(.csGhost)
                }
                .padding(Spacing.s6)
            }
            .padding(.horizontal, Spacing.s6)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.csBg)
    }
}

#Preview {
    NavigationStack { CaptureView() }
        .environmentObject(AppState())
}
