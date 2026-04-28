

import SwiftUI


public struct ScannerContainerView: View {
    @ObservedObject var controller: ScannerController
    public var isScannerOverlay: Bool
    
    // Actions for the built-in overlay (if used)
    public var backAction: () -> Void
    public var helpAction: () -> Void
    public var torchAction: (Bool) -> Void
    public var flipAction: () -> Void
    public var galleryAction: () -> Void

    public init(
        controller: ScannerController,
        isScannerOverlay: Bool = false,
        backAction: @escaping () -> Void = {},
        helpAction: @escaping () -> Void = {},
        torchAction: @escaping (Bool) -> Void = {_ in},
        flipAction: @escaping () -> Void = {},
        galleryAction: @escaping () -> Void = {}
    ) {
        self.controller = controller
        self.isScannerOverlay = isScannerOverlay
        self.backAction = backAction
        self.helpAction = helpAction
        self.torchAction = torchAction
        self.flipAction = flipAction
        self.galleryAction = galleryAction
    }

    public var body: some View {
        ZStack {
            QRScannerView(
                torchOn: controller.torchOn,
                onScan: controller.onScan,
                flipTrigger: $controller.flipTrigger,
                galleryTrigger: $controller.galleryTrigger
            )
            .ignoresSafeArea()
            
            if isScannerOverlay {
                ScannerOverlay(
                    backAction: backAction,
                    helpAction: helpAction,
                    torchAction: { flag in
                        controller.toggleTorch()
                        torchAction(flag)
                    },
                        flipAction: {
                            controller.flipCamera()
                            flipAction()
                        },
                        galleryAction: {
                            controller.openGallery()
                            galleryAction()
                        }
                )
            }
        }
    }
}
