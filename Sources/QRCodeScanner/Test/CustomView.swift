//
//  ContentView.swift
//  ScannerDemoApp
//
//  Created by KARUN KUMAR on 25/04/26.
//

import SwiftUI
import QRCodeScanner

struct CustomView: View {
    @State private var showingScanner = false
    // 1. Create the state object
    @StateObject private var scannerController = ScannerController()
    
    var body: some View {
        Button("Launch Scanner") {
            showingScanner = true
        }
        .fullScreenCover(isPresented: $showingScanner) {
            ZStack {
                // 2. Place the Scanner (Background)
                ScannerContainerView(controller: scannerController, isScannerOverlay: false)
                    .onAppear {
                        // 3. Set the scan callback
                        scannerController.onScan = { code in
                            print("Scanned: \(code)")
                            showingScanner = false
                        }
                    }
                
                // 4. Custom UI Overlay
                VStack {
                    HStack {
                        Button("Back") {
                            print("User pressed back")
                            showingScanner = false
                        }
                        Spacer()
                        Button("Help") {
                            print("Help pressed")
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    HStack(spacing: 40) {
                        Button("Flash") {
                            print("User Flash Toggle")
                            scannerController.toggleTorch()
                        }
                        
                        Button("Flip Camera") {
                            print("User Flip")
                            scannerController.flipCamera()
                        }
                        
                        Button("Open Gallery") {
                            print("User Gallery")
                            scannerController.openGallery()
                        }
                    }
                    .padding(.bottom, 30)
                }
                .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    CustomView()
}


