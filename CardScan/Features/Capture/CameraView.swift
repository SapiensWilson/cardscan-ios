import SwiftUI
import AVFoundation

/// Full-screen camera capture view.
/// Presented as .fullScreenCover from CaptureView.
struct CameraView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @StateObject private var camera = CameraController()
    @State private var flashOn = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Live preview
            CameraPreviewLayer(session: camera.session)
                .ignoresSafeArea()

            // Card-guide overlay
            CardGuideOverlay()

            // Controls
            VStack {
                topBar
                Spacer()
                bottomBar
            }
            .padding(.vertical, Spacing.s6)
        }
        .onAppear  { camera.start() }
        .onDisappear { camera.stop() }
        .onChange(of: camera.capturedImage) { _, img in
            guard let img else { return }
            appState.capturedImage = img
            dismiss()
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
            Spacer()
            if camera.hasTorch {
                Button {
                    flashOn.toggle()
                    camera.setTorch(flashOn)
                } label: {
                    Image(systemName: flashOn ? "bolt.fill" : "bolt.slash")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(flashOn ? Color.yellow : .white)
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, Spacing.s5)
    }

    // MARK: — Bottom bar
    private var bottomBar: some View {
        HStack(spacing: Spacing.s10) {
            // Flip camera
            Button {
                camera.flipCamera()
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath.camera")
                    .font(.system(size: 22))
                    .foregroundStyle(.white)
                    .frame(width: 50, height: 50)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }

            // Shutter
            Button {
                camera.capturePhoto()
            } label: {
                ZStack {
                    Circle()
                        .fill(.white)
                        .frame(width: 72, height: 72)
                    Circle()
                        .strokeBorder(.white.opacity(0.4), lineWidth: 3)
                        .frame(width: 84, height: 84)
                }
            }

            // Spacer placeholder to balance layout
            Color.clear.frame(width: 50, height: 50)
        }
    }
}

// MARK: — Card guide overlay
private struct CardGuideOverlay: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width * 0.85
            let h = w * 0.58   // standard business card aspect ratio 3.5:2
            let x = (geo.size.width  - w) / 2
            let y = (geo.size.height - h) / 2

            ZStack {
                // Dimmed surround
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

                // Guide border
                RoundedRectangle(cornerRadius: Radius.lg)
                    .strokeBorder(.white.opacity(0.7), lineWidth: 1.5)
                    .frame(width: w, height: h)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)

                // Corner accents
                CornerAccents(width: w, height: h)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
            }
        }
    }
}

private struct CornerAccents: View {
    let width: CGFloat
    let height: CGFloat
    private let len: CGFloat = 22
    private let thick: CGFloat = 3

    var body: some View {
        ZStack {
            // Top-left
            corner(xSign: -1, ySign: -1)
            // Top-right
            corner(xSign:  1, ySign: -1)
            // Bottom-left
            corner(xSign: -1, ySign:  1)
            // Bottom-right
            corner(xSign:  1, ySign:  1)
        }
    }

    @ViewBuilder
    private func corner(xSign: CGFloat, ySign: CGFloat) -> some View {
        let x = xSign * (width  / 2)
        let y = ySign * (height / 2)
        Path { p in
            p.move(to:    CGPoint(x: x, y: y - ySign * len))
            p.addLine(to: CGPoint(x: x, y: y))
            p.addLine(to: CGPoint(x: x - xSign * len, y: y))
        }
        .stroke(Color.csGreen, style: StrokeStyle(lineWidth: thick, lineCap: .round))
    }
}

// MARK: — SwiftUI wrapper for AVCaptureVideoPreviewLayer
struct CameraPreviewLayer: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewUIView {
        let view = PreviewUIView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewUIView, context: Context) {}

    class PreviewUIView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    }
}
