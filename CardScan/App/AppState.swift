import SwiftUI
import Combine

final class AppState: ObservableObject {

    // MARK: — Flow
    enum Step { case capture, processing, review, export }
    @Published var step: Step = .capture

    // MARK: — Scan data
    @Published var capturedImage: UIImage?  = nil
    @Published var processedImage: UIImage? = nil
    @Published var rawOCRText: String       = ""
    @Published var contact: ContactFields   = ContactFields()

    // MARK: — Processing state
    @Published var isProcessing: Bool      = false
    @Published var processingStatus: String = "Running OCR on your card…"
    @Published var processingProgress: Double = 0

    // MARK: — Toast
    @Published var toastMessage: String? = nil

    // MARK: — Alert
    @Published var activeAlert: AppAlert? = nil

    func showToast(_ message: String) {
        toastMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) { [weak self] in
            self?.toastMessage = nil
        }
    }

    func showAlert(_ alert: AppAlert) {
        activeAlert = alert
    }

    // MARK: — Reset
    func reset() {
        capturedImage     = nil
        processedImage    = nil
        rawOCRText        = ""
        contact           = ContactFields()
        isProcessing      = false
        processingProgress = 0
        step              = .capture
    }
}
