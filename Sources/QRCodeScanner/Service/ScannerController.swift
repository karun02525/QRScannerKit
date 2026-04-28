import SwiftUI
import Combine

@MainActor
public class ScannerController: ObservableObject {

    // MARK: - Published State
    @Published public var torchOn:        Bool = false
    @Published public var flipTrigger:    Bool = false
    @Published public var galleryTrigger: Bool = false

    // MARK: - Callback (Camera-thread safe)

    public nonisolated(unsafe) var onScan: (String) -> Void = { _ in }

    public nonisolated init() {}

    deinit {
        onScan = { _ in }
    }

    // MARK: - Control Methods
    public func toggleTorch() { torchOn.toggle()        }
    public func flipCamera()  { flipTrigger.toggle()    }
    public func openGallery() { galleryTrigger.toggle() }
}
