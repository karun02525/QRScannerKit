//
//  ScannerController.swift
//  QRCodeScanner
//
//  Created by KARUN KUMAR on 28/04/26.
//


import SwiftUI
import Combine

@MainActor
public class ScannerController: ObservableObject {
    @Published public var torchOn: Bool = false
    @Published public var flipTrigger: Bool = false
    @Published public var galleryTrigger: Bool = false
    
    // Callback for when a code is found
    public var onScan: (String) -> Void = { _ in }
    
    public init() {}
    
    public func toggleTorch() {
        torchOn.toggle()
    }
    
    public func flipCamera() {
        flipTrigger.toggle()
    }
    
    public func openGallery() {
        galleryTrigger.toggle()
    }
}
