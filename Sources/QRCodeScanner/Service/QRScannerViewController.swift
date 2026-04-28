import Foundation
@preconcurrency import AVFoundation
import UIKit
import PhotosUI
import Vision

// MARK: ═══════════════════════════════════════════════════════
// MARK:  QRScannerViewController
// MARK: ═══════════════════════════════════════════════════════

public class QRScannerViewController: UIViewController,
                                      AVCaptureMetadataOutputObjectsDelegate {

    // ── Public API ────────────────────────────────────────────
    public var onScan:    ((String) -> Void)?
    public var isScanned: Bool = false

    // ── Session Properties ────────────────────────────────────
    public var captureSession: AVCaptureSession!
    public var previewLayer:   AVCaptureVideoPreviewLayer!

    private var currentPosition: AVCaptureDevice.Position = .back

    private let sessionQueue = DispatchQueue(
        label: "com.scanner.sessionQueue",
        qos:   .userInitiated
    )

    // ── Lifecycle ─────────────────────────────────────────────

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupScanner(position: .back)
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSession()
    }

    // ─────────────────────────────────────────────────────────
    // MARK: – Scanner Setup
    // ─────────────────────────────────────────────────────────

    private func setupScanner(position: AVCaptureDevice.Position) {
        let session = AVCaptureSession()
        self.captureSession = session

        guard
            let device = bestCamera(for: position),
            let input  = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else {
            showPermissionAlert()
            return
        }

        session.addInput(input)
        currentPosition = position

        let output = AVCaptureMetadataOutput()
        guard session.canAddOutput(output) else { return }
        session.addOutput(output)

        output.setMetadataObjectsDelegate(self, queue: sessionQueue)
        output.metadataObjectTypes = supportedCodeTypes(for: session)

        let layer          = AVCaptureVideoPreviewLayer(session: session)
        layer.frame        = view.bounds
        layer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(layer, at: 0)
        self.previewLayer  = layer

        sessionQueue.async { session.startRunning() }
    }

    // ─────────────────────────────────────────────────────────
    // MARK: – Metadata Delegate
    // ─────────────────────────────────────────────────────────

    public nonisolated func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard
            let obj   = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
            let value = obj.stringValue
        else { return }

        Task { @MainActor in
            guard !self.isScanned else { return }
            self.isScanned = true
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            self.toggleTorch(on: false)
            self.stopSession()
            self.onScan?(value)
        }
    }

    // ─────────────────────────────────────────────────────────
    // MARK: – Torch
    // ─────────────────────────────────────────────────────────

    public func toggleTorch(on: Bool) {
        guard
            currentPosition == .back,
            let device = AVCaptureDevice.default(for: .video),
            device.hasTorch
        else { return }

        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("⚠️ Torch error: \(error.localizedDescription)")
        }
    }

    // ─────────────────────────────────────────────────────────
    // MARK: – Flip Camera
    // ─────────────────────────────────────────────────────────

    public func flipCamera() {
        let targetPosition: AVCaptureDevice.Position =
            currentPosition == .back ? .front : .back

        toggleTorch(on: false)

        sessionQueue.async { [weak self] in
            guard let self else { return }

            guard
                let newDevice = self.bestCamera(for: targetPosition),
                let newInput  = try? AVCaptureDeviceInput(device: newDevice)
            else {
                print("⚠️ Flip failed — no camera at: \(targetPosition.rawValue)")
                return
            }

            self.captureSession.beginConfiguration()

            self.captureSession.inputs
                .compactMap { $0 as? AVCaptureDeviceInput }
                .filter     { $0.device.hasMediaType(.video) }
                .forEach    { self.captureSession.removeInput($0) }

            if self.captureSession.canAddInput(newInput) {
                self.captureSession.addInput(newInput)
                Task { @MainActor in self.currentPosition = targetPosition }
            }

            self.captureSession.commitConfiguration()

            Task { @MainActor in
                self.applyFlipAnimation()
                self.previewLayer.connection?.automaticallyAdjustsVideoMirroring = false
                self.previewLayer.connection?.isVideoMirrored = (targetPosition == .front)
            }
        }
    }

    private func applyFlipAnimation() {
        let transition            = CATransition()
        transition.duration       = 0.38
        transition.type           = .fade
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.subtype        = .fromLeft
        previewLayer.add(transition, forKey: "cameraFlip")
    }

    // ─────────────────────────────────────────────────────────
    // MARK: – Gallery Scanner
    // ─────────────────────────────────────────────────────────

    public func openGalleryScanner() {
        pauseSession()

        var config                              = PHPickerConfiguration(photoLibrary: .shared())
        config.filter                           = .images
        config.selectionLimit                   = 1
        config.preferredAssetRepresentationMode = .current

        let picker      = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    // ─────────────────────────────────────────────────────────
    // MARK: – Session Helpers
    // ─────────────────────────────────────────────────────────

    private func stopSession() {
        let session = captureSession
        sessionQueue.async { session?.stopRunning() }
    }

    private func pauseSession() {
        let session = captureSession
        sessionQueue.async { session?.stopRunning() }
    }

    public func resumeSession() {
        isScanned = false
        let session = captureSession
        sessionQueue.async { session?.startRunning() }
    }

    // ─────────────────────────────────────────────────────────
    // MARK: – nonisolated Utilities
    // ─────────────────────────────────────────────────────────

    private nonisolated func bestCamera(
        for position: AVCaptureDevice.Position
    ) -> AVCaptureDevice? {
        AVCaptureDevice.DiscoverySession(
            deviceTypes: [
                .builtInWideAngleCamera,
                .builtInDualCamera,
                .builtInTrueDepthCamera
            ],
            mediaType: .video,
            position:  position
        ).devices.first
    }

    private nonisolated func supportedCodeTypes(
        for session: AVCaptureSession
    ) -> [AVMetadataObject.ObjectType] {
        let wanted: [AVMetadataObject.ObjectType] = [
            .qr, .ean13, .ean8, .code128,
            .code39, .pdf417, .aztec, .dataMatrix, .upce
        ]
        guard let output = session.outputs
            .first(where: { $0 is AVCaptureMetadataOutput })
                as? AVCaptureMetadataOutput
        else { return wanted }

        return wanted.filter { output.availableMetadataObjectTypes.contains($0) }
    }

    // ─────────────────────────────────────────────────────────
    // MARK: – Permission Alert
    // ─────────────────────────────────────────────────────────

    private func showPermissionAlert() {
        let alert = UIAlertController(
            title:          "Camera Access Required",
            message:        "Please enable camera access in Settings to scan QR codes.",
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(title: "Open Settings", style: .default) { _ in
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url)
            }
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: ═══════════════════════════════════════════════════════
// MARK:  PHPickerViewControllerDelegate
// MARK: ═══════════════════════════════════════════════════════

extension QRScannerViewController: PHPickerViewControllerDelegate {

    public func picker(
        _ picker: PHPickerViewController,
        didFinishPicking results: [PHPickerResult]
    ) {
        // ✅ PHPicker delegate fires on MainActor — safe to call loadImageAndScan
        picker.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            guard let result = results.first else {
                self.resumeSession()
                return
            }
            self.loadImageAndScan(from: result)
        }
    }

    // ── Step 1: Load UIImage  (called on MainActor) ───────────
    // ✅ @MainActor — safe to call showGalleryAlert / resumeSession directly
    private func loadImageAndScan(from result: PHPickerResult) {
        guard result.itemProvider.canLoadObject(ofClass: UIImage.self) else {
            showGalleryAlert(title:   "Unsupported Format",
                             message: "Please choose a JPEG, PNG, or HEIC photo.")
            resumeSession()
            return
        }

        // itemProvider completion fires on BACKGROUND thread
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            guard let self else { return }

            if let error {
                print("⚠️ Image load error: \(error.localizedDescription)")
                // ✅ Hop back to MainActor for any UI call
                Task { @MainActor in
                    self.showGalleryAlert(title:   "Load Failed",
                                         message: "Could not load the selected image.")
                    self.resumeSession()
                }
                return
            }

            guard
                let image   = object as? UIImage,
                let cgImage = image.cgImage
            else {
                Task { @MainActor in
                    self.showGalleryAlert(title:   "Invalid Image",
                                         message: "The image data could not be read.")
                    self.resumeSession()
                }
                return
            }

            let orientation = image.cgImageOrientation

            // ✅ detectCodes is nonisolated — safe to call from background thread
            self.detectCodes(in: cgImage, orientation: orientation)
        }
    }

    // ── Step 2: Vision Detection ──────────────────────────────
    // ✅ KEY FIX: nonisolated — can be called from background thread
    //    No direct @MainActor property access — all UI via Task { @MainActor in }
    private nonisolated func detectCodes(
        in cgImage:   CGImage,
        orientation:  CGImagePropertyOrientation
    ) {
        let request = VNDetectBarcodesRequest { [weak self] request, error in
            guard let self else { return }

            if let error {
                print("⚠️ Vision error: \(error.localizedDescription)")
                // ✅ Hop to MainActor for UI
                Task { @MainActor in
                    self.showGalleryAlert(title:   "Detection Failed",
                                         message: "An error occurred while analysing the image.")
                    self.resumeSession()
                }
                return
            }

            let observations = (request.results as? [VNBarcodeObservation]) ?? []
            let best = observations
                .filter  { $0.payloadStringValue != nil }
                .sorted  { $0.confidence > $1.confidence }
                .first

            guard let value = best?.payloadStringValue else {
                // ✅ Hop to MainActor for UI
                Task { @MainActor in self.showNoCodeFoundAlert() }
                return
            }

            // ✅ Hop to MainActor to deliver result
            Task { @MainActor in
                guard !self.isScanned else { return }
                self.isScanned = true
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                self.onScan?(value)
            }
        }

        request.symbologies = [
            .QR, .EAN13, .EAN8,
            .code128, .code39,
            .PDF417, .Aztec,
            .DataMatrix, .UPCE
        ]

        // ✅ handler.perform runs entirely on background — no actor crossing
        let handler = VNImageRequestHandler(
            cgImage:     cgImage,
            orientation: orientation,
            options:     [:]
        )

        do {
            try handler.perform([request])   // ✅ NO MORE CRASH
        } catch {
            print("⚠️ VNImageRequestHandler error: \(error.localizedDescription)")
        }
    }

    // ── Alert Helpers (called on MainActor) ───────────────────

    private func showNoCodeFoundAlert() {
        let alert = UIAlertController(
            title:          "No Code Found",
            message:        "The selected image doesn't contain a recognisable QR or barcode.",
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(title: "Try Again", style: .default) { [weak self] _ in
                self?.openGalleryScanner()
            }
        )
        alert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
                self?.resumeSession()
            }
        )
        present(alert, animated: true)
    }

    private func showGalleryAlert(title: String, message: String) {
        let alert = UIAlertController(
            title:          title,
            message:        message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: ═══════════════════════════════════════════════════════
// MARK:  UIImage → CGImagePropertyOrientation
// MARK: ═══════════════════════════════════════════════════════

private extension UIImage {
    var cgImageOrientation: CGImagePropertyOrientation {
        switch imageOrientation {
        case .up:            return .up
        case .down:          return .down
        case .left:          return .left
        case .right:         return .right
        case .upMirrored:    return .upMirrored
        case .downMirrored:  return .downMirrored
        case .leftMirrored:  return .leftMirrored
        case .rightMirrored: return .rightMirrored
        @unknown default:    return .up
        }
    }
}
