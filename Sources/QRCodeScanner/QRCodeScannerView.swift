import SwiftUI

// 1. Added 'public' so the struct is visible outside the library module
public struct QRCodeScannerView: View {
    
    public var onScanSuccess: (String) -> Void
    public var onDismiss: () -> Void
    public var isVisibleFrame: Bool
    
    @State private var isTorchOn: Bool = false
    
    // 2. Initializer must be public
    public init(
        onScanSuccess: @escaping (String) -> Void,
        onDismiss: @escaping () -> Void,
        isVisibleFrame: Bool = true // Added default value for convenience
    ) {
        self.onScanSuccess = onScanSuccess
        self.onDismiss = onDismiss
        self.isVisibleFrame = isVisibleFrame
    }
    
    // 3. 'body' must be public for SwiftUI to render it from another module
    public var body: some View {
        ZStack {
            QRScannerView(onScan: { code in
                onScanSuccess(code)
            }, torchOn: isTorchOn)
            
            if isVisibleFrame {
                ScannerOverlay(
                    backAction: {
                        onDismiss()
                    },
                    helpAction: {
                        // Optional closure could go here
                    },
                    torchAction: { isOn in
                        isTorchOn = isOn
                    }
                )
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    QRCodeScannerView(
        onScanSuccess: { _ in },
        onDismiss: {},
        isVisibleFrame: true
    )
}
