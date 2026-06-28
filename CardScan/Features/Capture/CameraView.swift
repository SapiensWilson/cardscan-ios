import SwiftUI
import AVFoundation

struct CameraView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @StateObject private var camera = CameraController()
    @State private var flashOn = false
    @State private var permissionDenied = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if permissionDenied {
                permissionDeniedOverlay
            } else {
                CameraPreviewLayer(session: camera.session)
                    .ignoresSafeArea()
                    .accessibilityHidden(true)

                CardGuideOverlay()
                    .accessibilityHidden(true)

                VStack {
                    topBar
                    Spacer()
                    bottomBar
                }
                .padding(.vertical, Spacing.s6)
            }
        }
        .task { await checkPermission() }
        .onDisappear { camera.stop() }
        .onChange(of: camera.capturedImage) { _, img in
            guard let img else { return }
            appState.capturedImage = img
            dismiss()
        }
    }

    // MARK: — Permission check
    private func checkPermission() async {
        switch CameraPermission.check() {
        case .granted:
            camera.start()
        case .requesting:
            let granted = await CameraPermission.request()
            if granted { camera.start() } else { permissionDenied = true }
        case .denied, .restricted:
            permissionDenied = true
        }
    }

    // MARK: — Permission denied overlay
    private var permissionDeniedOverlay: some View {
        VStack(spacing: Spacing.s6) {
            Spacer()
            Image(systemName: "camera.slash")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(.white.opacity(0.6))
                .accessibilityHidden(true)
            Text("Camera Access Required")
                .font(.csBaseSB)
                .foregroundStyle(.white)
            Text("Please enable Camera access in Settings to scan business cards.")
                .font(.csSM)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.s8)
            Button("Open Settings") {
                CameraPermission.openSettings()
            }
            .buttonStyle(.csPrimary)
            Button("Cancel") { dismiss() }
                .font(.csSM)
                .foregroundStyle(.white.opacity(0.6))
                .padding(.top, Spacing.s2)
            Spacer()
        }
    }

    // MARK: — Top bar
    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            .accessibilityLabel("Close camera")

            Spacer()

            if camera.hasTorch {
                Button {
                    flashOn.toggle()
                    camera.setTorch(flashOn)
                    Haptics.light()
                } label: {
                    Image(systemName: flashOn ? "bolt.fill" : "bolt.slash")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(flashOn ? Color.yellow : .white)
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .accessibilityLabel(flashOn ? "Torch on" : "Torch off")
                .accessibilityHint("Double tap to toggle torch")
            }
        }
        .padding(.horizontal, Spacing.s5)
    }

    // MARK: — Bottom bar
    private var bottomBar: some View {
        HStack(spacing: Spacing.s10) {
            Button {
                camera.flipCamera()
                Haptics.light()
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath.camera")
                    .font(.system(size: 22))
                    .foregroundStyle(.white)
                    .frame(width: 50, height: 50)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            .accessibilityLabel("Flip camera")

            Button {
                camera.capturePhoto()
                Haptics.medium()
            } label: {
                ZStack {
                    Circle().fill(.white).frame(width: 72, height: 72)
                    Circle().strokeBorder(.white.opacity(0.4), lineWidth: 3)
                        .frame(width: 84, height: 84)
                }
            }
            .accessibilityLabel("Capture photo")
            .accessibilityHint("Takes a photo of the business card")

            Color.clear.frame(width: 50, height: 50)
                .accessibilityHidden(true)
        }
    }
}

// MARK: — Card guide overlay
private struct CardGuideOverlay: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width * 0.85
            let h = w * 0.58
            ZStack {
                Rectangle()
                    .fill(.black.opacity(0.45))
                    .mask {
                        Rectangle()
                            .overlay {
                                RoundedRectangle(cornerRadius: Radius.lg)
                                    .frame(width: w, height: h)
                                    .blendMode(.destinationOut)
                            }
                    }
                    .ignoresSafeArea()
                RoundedRectangle(cornerRadius: Radius.lg)
                    .strokeBorder(.white.opacity(0.7), lineWidth: 1.5)
                    .frame(width: w, height: h)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                CornerAccents(width: w, height: h)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
            }
        }
    }
}

private struct CornerAccents: View {
    let width: CGFloat
    let height: CGFloat
    private let len: CGFloat   = 22
    private let thick: CGFloat = 3
    var body: some View {
        ZStack {
            corner(xSign: -1, ySign: -1); corner(xSign:  1, ySign: -1)
            corner(xSign: -1, ySign:  1); corner(xSign:  1, ySign:  1)
        }
    }
    @ViewBuilder
    private func corner(xSign: CGFloat, ySign: CGFloat) -> some View {
        let x = xSign * (width / 2); let y = ySign * (height / 2)
        Path { p in
            p.move(to:    CGPoint(x: x, y: y - ySign * len))
            p.addLine(to: CGPoint(x: x, y: y))
            p.addLine(to: CGPoint(x: x - xSign * len, y: y))
        }
        .stroke(Color.csGreen, style: StrokeStyle(lineWidth: thick, lineCap: .round))
    }
}

struct CameraPreviewLayer: UIViewRepresentable {
    let session: AVCaptureSession
    func makeUIView(context: Context) -> PreviewUIView {
        let view = PreviewUIView()
        view.previewLayer.session      = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }
    func updateUIView(_ uiView: PreviewUIView, context: Context) {}
    class PreviewUIView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    }
}
