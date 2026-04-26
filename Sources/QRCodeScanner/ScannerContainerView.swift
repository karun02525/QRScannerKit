import SwiftUI

public struct ScannerContainerView: View {
    
    // MARK: - Properties
    public var onScan: (String) -> Void
    public var backAction: () -> Void
    public var helpAction: () -> Void
    public var torchAction: (Bool) -> Void
    public var flipAction: () -> Void
    public var galleryAction: () -> Void
    public var isScannerOverlay: Bool
    
    // MARK: - Internal State
    @State private var torchOn: Bool = false
    @State private var flipTrigger: Bool = false
    @State private var galleryTrigger: Bool = false
    
    // MARK: - Initializer
    public init(
        isScannerOverlay: Bool = true,
        onScan: @escaping (String) -> Void,
        backAction: @escaping () -> Void = {},
        helpAction: @escaping () -> Void = {},
        torchAction: @escaping (Bool) -> Void = { _ in },
        flipAction: @escaping () -> Void = {},
        galleryAction: @escaping () -> Void = {}
    ) {
        self.isScannerOverlay = isScannerOverlay
        self.onScan = onScan
        self.backAction = backAction
        self.helpAction = helpAction
        self.torchAction = torchAction
        self.flipAction = flipAction
        self.galleryAction = galleryAction
    }

    // MARK: - Body
    public var body: some View {
        ZStack {
            QRScannerView(
                torchOn: torchOn,
                onScan: onScan,
                flipTrigger: $flipTrigger,
                galleryTrigger: $galleryTrigger
            )
            .ignoresSafeArea()
            
            if isScannerOverlay {
                ScannerOverlay(
                    backAction: backAction,
                    helpAction: helpAction,
                    torchAction: { isOn in
                        self.torchOn = isOn
                        self.torchAction(isOn) // Pass the value to the callback
                    },
                    flipAction: {
                        self.flipTrigger.toggle()
                        self.flipAction()
                    },
                    galleryAction: {
                        self.galleryTrigger.toggle()
                        self.galleryAction()
                    }
                )
            }
        }
    }
}

#Preview {
    ScannerContainerView { code in
        print("Scanned: \(code)")
    }
}
