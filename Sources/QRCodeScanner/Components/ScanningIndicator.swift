//
//  ScanningIndicator.swift
//  QRCodeScanner
//
//  Created by KARUN KUMAR on 25/04/26.
//


import SwiftUI
import Combine

// MARK: - "Scanning ●●●" animated label
struct ScanningIndicator: View {

    @State private var dotPhase: Int = 0

    // fires on main run-loop — safe for UI
    private let ticker = Timer
        .publish(every: 0.45, on: .main, in: .common)
        .autoconnect()

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "qrcode.viewfinder")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.55))

            Text("Scanning")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.78))

            // Three animated dots
            HStack(spacing: 3) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(i < dotPhase
                              ? Color.white
                              : Color.white.opacity(0.2))
                        .frame(width: 4, height: 4)
                        .animation(
                            .easeInOut(duration: 0.15),
                            value: dotPhase
                        )
                }
            }
        }
        .onReceive(ticker) { _ in
            dotPhase = (dotPhase % 3) + 1   // cycles 1 → 2 → 3 → 1 …
        }
    }
}