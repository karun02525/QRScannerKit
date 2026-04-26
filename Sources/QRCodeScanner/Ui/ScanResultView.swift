//
//  ScanResultView.swift
//  QRCodeScanner
//
//  Created by KARUN KUMAR on 25/04/26.
//

import SwiftUI


struct ScanResultView: View {
    let code:      String
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            // Header
            Image(systemName: "qrcode.viewfinder")
                .font(.system(size: 52))
                .foregroundStyle(.green)

            Text("Code Detected")
                .font(.title2.bold())

            // Result box
            Text(code)
                .font(.system(.body, design: .monospaced))
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)

            // Copy button
            Button {
                UIPasteboard.general.string = code
            } label: {
                Label("Copy to Clipboard", systemImage: "doc.on.doc")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal)
            }

            // Dismiss
            Button("Scan Another", action: onDismiss)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 40)
        .padding(.bottom, 24)
    }
}
