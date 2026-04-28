//
//  QRScannerView.swift
//  iosApp
//
//  Created by KARUN KUMAR on 24/04/26.
//

import Foundation
import SwiftUI


struct QRScannerView: UIViewControllerRepresentable {
    var onScan: (String) -> Void
    var torchOn: Bool
    func makeUIViewController(context: Context) -> QRScannerViewController {
        let vc = QRScannerViewController()
        vc.onScan = onScan
        return vc
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        uiViewController.toggleTorch(flag: torchOn)
    }
}
