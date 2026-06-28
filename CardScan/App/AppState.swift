import SwiftUI
import Combine

/// Shared application state threaded via @EnvironmentObject.
final class AppState: ObservableObject {

    // MARK: — Flow
    enum Step { case capture, processing, review, export }
    @Published var step: Step = .capture

    // MARK: — Scan data
    /// The image selected/captured by the user (original, full-res).
    @Published var capturedImage: UIImage? = nil
    /// Pre-processed image shown in Review.
    @Published var processedImage: UIImage? = nil
    /// Raw OCR output string.
    @Published var rawOCRText: String = ""
    /// Parsed contact fields.
    @Published var contact: ContactFields = ContactFields()

    // MARK: — UI state
    @Published var isProcessing: Bool = false
    @Published var processingStatus: String = "Running OCR on your card…"
    @Published var processingProgress: Double = 0

    // MARK: — Toast
    @Published var toastMessage: String? = nil

    func showToast(_ message: String) {
        toastMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) { [weak self] in
            self?.toastMessage = nil
        }
    }

    // MARK: — Reset
    func reset() {
        capturedImage = nil
        processedImage = nil
        rawOCRText = ""
        contact = ContactFields()
        isProcessing = false
        processingProgress = 0
        step = .capture
    }
}
