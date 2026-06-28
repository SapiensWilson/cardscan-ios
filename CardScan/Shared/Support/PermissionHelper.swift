import AVFoundation
import UIKit

/// Checks and requests camera authorisation.
/// Returns the action to take based on the current status.
enum CameraPermission {

    enum Status {
        case granted
        case denied      // show alert + Settings button
        case restricted  // show alert only
        case requesting  // async in-flight
    }

    static func check() -> Status {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:      return .granted
        case .denied:          return .denied
        case .restricted:      return .restricted
        case .notDetermined:   return .requesting
        @unknown default:      return .denied
        }
    }

    /// Async wrapper around requestAccess. Returns true if granted.
    static func request() async -> Bool {
        await AVCaptureDevice.requestAccess(for: .video)
    }

    /// Opens the app's Settings page so the user can flip the permission.
    static func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        Task { @MainActor in
            await UIApplication.shared.open(url)
        }
    }
}
