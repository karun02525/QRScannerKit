// ─────────────────────────────────────────────
// ScannerController.swift
// ─────────────────────────────────────────────
import SwiftUI
import Combine

/// Acts as the single source of truth between the SwiftUI scanner view
/// and the Kotlin/Compose layer via IOSBridgeImpl.
///
/// - All `@Published` mutations are `@MainActor`-isolated (safe for SwiftUI).
/// - `onScan` is `nonisolated(unsafe)` so AVFoundation's background
///   camera thread can invoke it without a Swift Concurrency isolation
///   violation. The closure body (set in IOSBridgeImpl) always dispatches
///   its work back to the main thread before touching shared state.
///   Requires Swift 5.10 / Xcode 15.3+.
@MainActor
public class ScannerController: ObservableObject {

    // MARK: - Published State (SwiftUI-driven)

    /// Reflects the current torch / flashlight state.
    @Published public var torchOn: Bool = false

    /// Toggled to trigger a camera flip in the scanner view.
    @Published public var flipTrigger: Bool = false

    /// Toggled to open the photo gallery picker in the scanner view.
    @Published public var galleryTrigger: Bool = false

    // MARK: - Callback (Camera-thread safe)

    /// Called by the scanner view when a QR/barcode is successfully decoded.
    /// Marked `nonisolated(unsafe)` because AVFoundation delivers scan
    /// results on a private background thread, outside of `@MainActor`.
    /// Assign this exactly once before the view appears; never reassign
    /// it from multiple threads concurrently.
    public nonisolated(unsafe) var onScan: (String) -> Void = { _ in }

    // MARK: - Init / Deinit

    public init() {}

    deinit {
        // Break the closure reference explicitly so any captured objects
        // (e.g. CameraPreviewState) are released when the controller goes away.
        onScan = { _ in }
    }

    // MARK: - Control Methods (called from IOSBridgeImpl closures)

    /// Toggles the torch on/off.
    public func toggleTorch() {
        torchOn.toggle()
    }

    /// Signals the scanner view to flip between front and back cameras.
    public func flipCamera() {
        flipTrigger.toggle()
    }

    /// Signals the scanner view to open the system photo-gallery picker.
    public func openGallery() {
        galleryTrigger.toggle()
    }
}
