import Foundation
@preconcurrency import AVFoundation // ✅ Suppresses legacy Sendable warnings from AVFoundation
import UIKit

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    // Main Actor-isolated properties
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var onScan: ((String) -> Void)?
    var isScanned = false

    // Background queue for session management (prevents UI lag)
    private let sessionQueue = DispatchQueue(label: "com.scanner.sessionQueue")

    override func viewDidLoad() {
        super.viewDidLoad()
        setupScanner()
    }

    private func setupScanner() {
        let session = AVCaptureSession()
        self.captureSession = session

        guard let videoDevice = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: videoDevice),
              session.canAddInput(input) else { return }

        session.addInput(input)

        let output = AVCaptureMetadataOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            // Set delegate to run on the background session queue
            output.setMetadataObjectsDelegate(self, queue: sessionQueue)
            output.metadataObjectTypes = [.qr]
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        // ✅ Use the local 'session' reference to avoid Sendable closure warnings
        sessionQueue.async {
            session.startRunning()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
    }

    // ✅ nonisolated: Satisfies the protocol without claiming MainActor isolation
    nonisolated func metadataOutput(_ output: AVCaptureMetadataOutput,
                                    didOutput metadataObjects: [AVMetadataObject],
                                    from connection: AVCaptureConnection) {

        guard let obj = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let value = obj.stringValue else { return }

        // ✅ Task {@MainActor}: Safely jump back to UI thread to update state
        Task { @MainActor in
            guard !self.isScanned else { return }
            self.isScanned = true
            
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            
            self.toggleTorch(flag: false)
            
            // Stop session on the background queue using a local reference
            let session = self.captureSession
            self.sessionQueue.async {
                session?.stopRunning()
            }

            self.onScan?(value)
        }
    }

    func toggleTorch(flag: Bool) {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            device.torchMode = flag ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("Torch error: \(error)")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let session = self.captureSession
        sessionQueue.async {
            if session?.isRunning == true {
                session?.stopRunning()
            }
        }
    }
}
