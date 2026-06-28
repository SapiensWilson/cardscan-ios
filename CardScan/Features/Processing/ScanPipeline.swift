import UIKit

/// Orchestrates the full scan pipeline:
/// CapturedImage → ImagePreprocessor → OCREngine → ContactParser → AppState
@MainActor
final class ScanPipeline {

    static func run(image: UIImage, appState: AppState) async {
        appState.isProcessing       = true
        appState.processingProgress = 0
        appState.processingStatus   = "Pre-processing image…"
        appState.step               = .processing

        do {
            // Phase A: Image pre-processing
            let preprocessResult = try await ImagePreprocessor.process(image) { status, pct in
                Task { @MainActor in
                    appState.processingStatus   = status
                    appState.processingProgress = pct * 0.4
                }
            }
            appState.processedImage = preprocessResult.image

            // Phase B: OCR
            appState.processingStatus = "Reading text…"
            let ocrResult = try await OCREngine.recognise(preprocessResult.image) { pct in
                Task { @MainActor in
                    appState.processingProgress = 0.4 + pct * 0.55
                }
            }

            // Guard: no text at all
            guard !ocrResult.fullText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                appState.isProcessing = false
                appState.step         = .capture
                Haptics.error()
                appState.showAlert(.noTextDetected())
                return
            }

            appState.rawOCRText = ocrResult.fullText

            // Phase C: Parse
            appState.processingStatus   = "Extracting contact info…"
            appState.processingProgress = 0.97
            appState.contact = ContactParser.parse(lines: ocrResult.lines, fullText: ocrResult.fullText)

            appState.processingProgress = 1.0
            appState.isProcessing       = false
            appState.step               = .review

        } catch {
            appState.isProcessing = false
            appState.step         = .capture
            Haptics.error()
            appState.showAlert(.ocrFailed(error.localizedDescription))
        }
    }
}
