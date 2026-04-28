//
//  MainAppView.swift
//  QRCodeScanner
//
//  Created by KARUN KUMAR on 25/04/26.
//

import SwiftUI

struct MainAppView: View {
    @State private var showingScanner = false
    
    var body: some View {
        Button("Launch Scanner") {
            showingScanner = true
        }
        .fullScreenCover(isPresented: $showingScanner) {
            // This is your library code running
            QRCodeScannerView(
                onScanSuccess: { code in
                    print("Found: \(code)")
                    showingScanner = false
                },
                onDismiss: {
                    showingScanner = false
                },
                isVisibleFrame: true
            )
        }
    }
}
