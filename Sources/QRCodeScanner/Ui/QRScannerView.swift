import SwiftUI
import AVFoundation

struct QRScannerView: UIViewControllerRepresentable {
    var torchOn:    Bool
    var onScan:     (String) -> Void
    @Binding var flipTrigger:   Bool
    @Binding var galleryTrigger: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator {
        weak var viewController: QRScannerViewController?
    }


    func makeUIViewController(context: Context) -> QRScannerViewController {
        let vc     = QRScannerViewController()
        vc.onScan  = onScan
        context.coordinator.viewController = vc
        return vc
    }

   

    func updateUIViewController(
        _ uiViewController: QRScannerViewController,
        context: Context
    ) {
      
        guard uiViewController.previewLayer != nil else { return }
        uiViewController.toggleTorch(on: torchOn)   // ✅ correct label

      
        if flipTrigger {
            uiViewController.flipCamera()
            DispatchQueue.main.async { flipTrigger = false }
        }

        if galleryTrigger {
            uiViewController.openGalleryScanner()
            DispatchQueue.main.async { galleryTrigger = false }
        }
    }
}
