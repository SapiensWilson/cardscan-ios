import Vision
import UIKit

/// Wraps VNRecognizeTextRequest for on-device OCR.
/// Returns all recognised text lines and a single joined raw string.
struct OCREngine {

    struct OCRResult {
        /// Individual recognised text lines, in document order.
        let lines: [String]
        /// Full text with newlines, for display and parsing.
        var fullText: String { lines.joined(separator: "\n") }
    }

    /// Progress callback: (0.0–1.0)
    typealias Progress = (Double) -> Void

    static func recognise(_ image: UIImage, progress: Progress) async throws -> OCRResult {
        return try await withCheckedThrowingContinuation { continuation in
            guard let cgImage = image.cgImage else {
                continuation.resume(throwing: OCRError.invalidImage)
                return
            }

            let request = VNRecognizeTextRequest { request, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let observations = request.results as? [VNRecognizedTextObservation] ?? []
                let lines = observations.compactMap {
                    $0.topCandidates(1).first?.string
                }
                continuation.resume(returning: OCRResult(lines: lines))
            }

            request.recognitionLevel       = .accurate
            request.usesLanguageCorrection = true
            request.recognitionLanguages   = ["en-US"]
            request.revision = VNRecognizeTextRequestRevision3

            // Simulate progress (Vision doesn't expose real progress)
            let progressSteps: [(Double, TimeInterval)] = [(0.25, 0.1), (0.5, 0.4), (0.75, 0.8)]
            for (pct, delay) in progressSteps {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) { progress(pct) }
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                    DispatchQueue.main.async { progress(1.0) }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    enum OCRError: Error {
        case invalidImage
    }
}
