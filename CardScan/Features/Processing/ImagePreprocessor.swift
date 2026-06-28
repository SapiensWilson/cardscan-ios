import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Accelerate

/// Mirrors the web app's canvas pre-processing pipeline using Core Image + vImage.
/// All work is done off the main thread — call from a Task or background queue.
struct ImagePreprocessor {

    struct Result {
        let image: UIImage
    }

    /// Progress callback: (statusMessage, 0.0–1.0)
    typealias Progress = (String, Double) -> Void

    static func process(_ input: UIImage, progress: Progress) async throws -> Result {
        return try await Task.detached(priority: .userInitiated) {
            try self.processSync(input, progress: progress)
        }.value
    }

    // MARK: — Synchronous pipeline (runs on background thread)
    private static func processSync(_ input: UIImage, progress: Progress) throws -> Result {
        let ctx = CIContext(options: [.useSoftwareRenderer: false])

        guard var ci = CIImage(image: input) else {
            throw PreprocessError.invalidImage
        }

        // 1. Upscale to minimum 1800px wide
        progress("Upscaling…", 0.06)
        let minWidth: CGFloat = 1800
        let scale = ci.extent.width < minWidth ? minWidth / ci.extent.width : 1.0
        if scale > 1 {
            ci = ci.transformed(by: .init(scaleX: scale, y: scale))
        }

        // 2. Grayscale
        progress("Converting to grayscale…", 0.15)
        let grayFilter = CIFilter.colorControls()
        grayFilter.inputImage  = ci
        grayFilter.saturation  = 0
        grayFilter.brightness  = 0
        grayFilter.contrast    = 1
        ci = grayFilter.outputImage ?? ci

        // 3. Contrast boost
        progress("Boosting contrast…", 0.25)
        let contrastFilter = CIFilter.colorControls()
        contrastFilter.inputImage = ci
        contrastFilter.saturation = 0
        contrastFilter.brightness = 0
        contrastFilter.contrast   = 1.35
        ci = contrastFilter.outputImage ?? ci

        // 4. Sharpen (Unsharp Mask)
        progress("Sharpening…", 0.38)
        let sharpen = CIFilter.unsharpMask()
        sharpen.inputImage = ci
        sharpen.radius     = 2.5
        sharpen.intensity  = 0.6
        ci = sharpen.outputImage ?? ci

        // 5. Adaptive threshold via vImage
        progress("Binarising…", 0.55)
        if let thresholded = try? adaptiveThreshold(ci, context: ctx) {
            ci = thresholded
        }

        // 6. Render to CGImage for output
        progress("Finishing…", 0.90)
        guard let cgImg = ctx.createCGImage(ci, from: ci.extent) else {
            throw PreprocessError.renderFailed
        }

        progress("Done", 1.0)
        return Result(image: UIImage(cgImage: cgImg))
    }

    // MARK: — Adaptive threshold (vImage)
    /// Sauvola-inspired local threshold: pixel is black if value < local mean * (1 - k)
    private static func adaptiveThreshold(_ ci: CIImage, context: CIContext) throws -> CIImage? {
        guard let cgImg = context.createCGImage(ci, from: ci.extent) else { return nil }

        let width  = cgImg.width
        let height = cgImg.height
        var srcBuf = vImage_Buffer()
        var dstBuf = vImage_Buffer()

        defer {
            free(srcBuf.data)
            free(dstBuf.data)
        }

        // Convert CGImage -> 8-bit planar vImage
        var fmt = vImage_CGImageFormat(
            bitsPerComponent: 8, bitsPerPixel: 8,
            colorSpace: Unmanaged.passRetained(CGColorSpaceCreateDeviceGray()),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
            version: 0, decode: nil, renderingIntent: .defaultIntent
        )
        defer { fmt.colorSpace.release() }

        guard vImageBuffer_InitWithCGImage(&srcBuf, &fmt, nil, cgImg, vImage_Flags(kvImageNoFlags)) == kvImageNoError else { return nil }
        guard vImageBuffer_Init(&dstBuf, vImagePixelCount(height), vImagePixelCount(width), 8, vImage_Flags(kvImageNoFlags)) == kvImageNoError else { return nil }

        // Box-blur for local mean (block radius ~32px)
        let radius: UInt32 = 31   // must be odd
        var blurBuf = vImage_Buffer()
        guard vImageBuffer_Init(&blurBuf, vImagePixelCount(height), vImagePixelCount(width), 8, vImage_Flags(kvImageNoFlags)) == kvImageNoError else { return nil }
        defer { free(blurBuf.data) }
        vImageBoxConvolve_Planar8(&srcBuf, &blurBuf, nil, 0, 0, radius, radius, 0, vImage_Flags(kvImageEdgeExtend))

        // Threshold: pixel < mean * 0.88 → black, else white
        let k: Float = 0.12
        let src  = srcBuf.data!.assumingMemoryBound(to: UInt8.self)
        let blur = blurBuf.data!.assumingMemoryBound(to: UInt8.self)
        let dst  = dstBuf.data!.assumingMemoryBound(to: UInt8.self)
        let count = width * height
        for i in 0..<count {
            let mean = Float(blur[i])
            let threshold = mean * (1.0 - k)
            dst[i] = Float(src[i]) >= threshold ? 255 : 0
        }

        // Convert back to CIImage
        guard let outCG = vImageCreateCGImageFromBuffer(&dstBuf, &fmt, nil, nil, vImage_Flags(kvImageNoFlags), nil)?.takeRetainedValue() else { return nil }
        return CIImage(cgImage: outCG)
    }

    enum PreprocessError: Error {
        case invalidImage
        case renderFailed
    }
}
