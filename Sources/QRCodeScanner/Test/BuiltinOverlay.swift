//
//  BuiltinOverlay.swift
//  ScannerDemoApp
//
//  Created by KARUN KUMAR on 28/04/26.
//

import SwiftUI
import QRCodeScanner


struct BuiltinOverlay: View {
    @State private var showingScanner = false
    @StateObject private var scannerController = ScannerController()
    
    var body: some View {
        VStack(spacing: 20) {
            Button("Launch Scanner with Overlay") {
                showingScanner = true
            }
        }
        .fullScreenCover(isPresented: $showingScanner) {
            // isScannerOverlay is TRUE here
            ScannerContainerView(
                controller: scannerController,
                isScannerOverlay: true,
                backAction: {
                    showingScanner = false
                    print("User tapped the backAction")
                },
                helpAction: {
                    print("User tapped the helpAction")
                },
                torchAction: { flag in
                    print("User tapped the torchAction \(flag)")
                },
                flipAction: {
                    print("User tapped the flipAction")
                },
                galleryAction : {
                    print("User tapped the galleryAction")
                }
            )
            .onAppear {
                scannerController.onScan = { code in
                    print("Found Code: \(code)")
                    showingScanner = false
                }
            }
        }
    }
}
