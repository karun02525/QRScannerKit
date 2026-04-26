# QRScannerKit 📸

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS%2016%2B-blue?style=for-the-badge&logo=apple" />
  <img src="https://img.shields.io/badge/Swift-6.0-orange?style=for-the-badge&logo=swift" />
  <img src="https://img.shields.io/badge/SPM-Compatible-brightgreen?style=for-the-badge" />
  <img src="https://img.shields.io/badge/License-MIT-lightgrey?style=for-the-badge" />
</p>

<p align="center">
  A professional, production-ready QR & Barcode scanner built with SwiftUI + AVFoundation.<br/>
  Drop-in one view. Get scanned results. That's it.
</p>

---

## 📸 Preview

<p align="center">
  <img src="https://github.com/user-attachments/assets/74a8591c-ce85-4393-a0be-1caa9bf10cef" width="280" />
  <img src="https://github.com/user-attachments/assets/3d8ca569-3d0b-4cb0-ba71-23c66ccc5459" width="280" />
 <p align="center">
  <video src="https://github.com/user-attachments/assets/32e57d2e-ce15-4cc3-9869-a33308b2b98d" width="300" controls>
    Your browser does not support the video tag.
  </video>
</p>
</p>


---

## 🚀 Installation

### Swift Package Manager
Add the following URL to your dependencies:
`https://github.com/karun02525/QRScannerKit`

---

## 💻 Usage

### Simple Implementation
```swift
import QRScannerKit

ScannerContainerView { code in
    print("Scanned result: \(code)")
}
## ✨ Features

- ✅ **Live QR & Barcode scanning** via `AVFoundation`
- ✅ **Flip camera** — front & back with smooth animation
- ✅ **Torch toggle** — with active glow feedback
- ✅ **Gallery scan** — pick any photo and extract codes via `Vision`
- ✅ **Animated scan overlay** — laser beam + corner bracket glow
- ✅ **Haptic feedback** on successful scan
- ✅ **Swift 6 concurrency safe** — `nonisolated`, `@MainActor`, `Task`
- ✅ **Zero dependencies** — pure Apple frameworks only
- ✅ **SwiftUI + UIKit bridge** — `UIViewControllerRepresentable`
- ✅ **One-line integration** — single view, single callback

---

## 📦 Requirements

| Requirement | Minimum |
|---|---|
| iOS | 16.0+ |
| Swift | 6.0+ |
| Xcode | 15.0+ |
| SwiftUI | 4.0+ |

---

## 🔧 Installation

### Swift Package Manager (Recommended)

#### Via Xcode UI
```
1. Open your project in Xcode
2. File → Add Package Dependencies
3. Enter URL: https://github.com/karun02525/QRScannerKit
4. Select Version: 1.0.0
5. Click Add Package
```

#### Via `Package.swift`
```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "YourApp",
    platforms: [.iOS(.v16)],
    dependencies: [
        .package(
            url: "https://github.com/karun02525/QRScannerKit",
            from: "1.0.0"
        )
    ],
    targets: [
        .target(
            name: "YourApp",
            dependencies: [
                .product(name: "QRCodeScanner", package: "QRScannerKit")
            ]
        )
    ]
)
```

---

## 🚀 Quick Start

### Step 1 — Add Privacy Keys to `Info.plist`

```xml
<!-- Required: Camera access -->
<key>NSCameraUsageDescription</key>
<string>We need camera access to scan QR codes and barcodes.</string>

<!-- Required: Gallery access (for gallery scan feature) -->
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to scan QR codes from your photos.</string>
```

> ⚠️ App will **crash on launch** without these keys on a real device.

---

### Step 2 — Import & Use (3 lines)

```swift
import SwiftUI
import QRCodeScanner  // ✅ One import

struct ContentView: View {

    @State private var showScanner = false
    @State private var scannedResult = ""

    var body: some View {
        VStack(spacing: 24) {

            Text(scannedResult.isEmpty ? "No code scanned yet" : scannedResult)
                .font(.body)
                .foregroundStyle(.secondary)
                .padding()

            Button("Scan QR Code") {
                showScanner = true
            }
            .buttonStyle(.borderedProminent)
        }
        // ✅ Present scanner — ONE line
        .fullScreenCover(isPresented: $showScanner) {
            ScannerContainerView { scannedValue in
                scannedResult = scannedValue   // ← your result here
                showScanner   = false          // ← auto dismiss
            }
        }
    }
}
```

---

## 📖 Full API Reference

### `ScannerContainerView`

> The **main entry point**. A complete, ready-to-use scanner screen with overlay, controls, and callbacks.

```swift
public struct ScannerContainerView: View {
    public init(onScanComplete: ((String) -> Void)? = nil)
}
```

#### Parameters

| Parameter | Type | Description |
|---|---|---|
| `onScanComplete` | `((String) -> Void)?` | Called on Main thread when a code is scanned. |

#### Usage Examples

```swift
// ✅ Basic — fullScreenCover
.fullScreenCover(isPresented: $showScanner) {
    ScannerContainerView { value in
        print("Scanned: \(value)")
    }
}

// ✅ Sheet
.sheet(isPresented: $showScanner) {
    ScannerContainerView { value in
        scannedResult = value
        showScanner   = false
    }
}

// ✅ NavigationLink push
NavigationLink {
    ScannerContainerView { value in
        scannedResult = value
    }
} label: {
    Text("Open Scanner")
}

// ✅ Inline swap (no navigation)
Group {
    if isScanning {
        ScannerContainerView { value in
            result     = value
            isScanning = false
        }
    } else {
        MainView()
    }
}
```

---

### `ScannerOverlay`

> The **UI overlay** layer only. Use this if you want to build a **custom camera integration** with your own `AVFoundation` session.

```swift
public struct ScannerOverlay: View {
    public init(
        backAction:    @escaping () -> Void,
        helpAction:    @escaping () -> Void,
        torchAction:   @escaping (Bool) -> Void,
        flipAction:    @escaping () -> Void    = {},
        galleryAction: @escaping () -> Void    = {}
    )
}
```

#### Parameters

| Parameter | Type | Description |
|---|---|---|
| `backAction` | `() -> Void` | Fires when back `←` button tapped |
| `helpAction` | `() -> Void` | Fires when `?` help button tapped |
| `torchAction` | `(Bool) -> Void` | Returns `true/false` torch state |
| `flipAction` | `() -> Void` | Fires when flip camera button tapped |
| `galleryAction` | `() -> Void` | Fires when gallery button tapped |

#### Usage

```swift
ScannerOverlay(
    backAction:    { dismiss()               },
    helpAction:    { showHelp = true         },
    torchAction:   { isOn in torchOn = isOn  },
    flipAction:    { flipTrigger    = true   },
    galleryAction: { galleryTrigger = true   }
)
```

---

### `QRScannerView`

> The **camera feed** as a SwiftUI view. Use this if you want the camera feed but with your **own overlay**.

```swift
public struct QRScannerView: UIViewControllerRepresentable {
    public init(
        torchOn:        Bool,
        onScan:         @escaping (String) -> Void,
        flipTrigger:    Binding<Bool>,
        galleryTrigger: Binding<Bool>
    )
}
```

#### Parameters

| Parameter | Type | Description |
|---|---|---|
| `torchOn` | `Bool` | Pass `true` to turn torch on |
| `onScan` | `(String) -> Void` | Called with scanned code value |
| `flipTrigger` | `Binding<Bool>` | Set to `true` to trigger camera flip |
| `galleryTrigger` | `Binding<Bool>` | Set to `true` to open gallery picker |

#### Usage — Custom Overlay

```swift
struct MyCustomScannerView: View {

    @State private var torchOn        = false
    @State private var flipTrigger    = false
    @State private var galleryTrigger = false

    var body: some View {
        ZStack {
            // ── Camera Feed ──────────────────────────
            QRScannerView(
                torchOn:        torchOn,
                onScan:         { value in print(value) },
                flipTrigger:    $flipTrigger,
                galleryTrigger: $galleryTrigger
            )
            .ignoresSafeArea()

            // ── Your Custom UI on top ────────────────
            VStack {
                Spacer()
                HStack {
                    Button("Torch") { torchOn.toggle() }
                    Button("Flip")  { flipTrigger    = true }
                    Button("Photo") { galleryTrigger = true }
                }
                .padding()
                .background(.ultraThinMaterial)
            }
        }
    }
}
```

---

### `QRScannerViewController`

> The raw `UIViewController`. Use this if you're working in a **UIKit app**.

```swift
public class QRScannerViewController: UIViewController
```

#### Properties

| Property | Type | Description |
|---|---|---|
| `onScan` | `((String) -> Void)?` | Callback when code is detected |
| `isScanned` | `Bool` | Prevents duplicate scan events |
| `captureSession` | `AVCaptureSession!` | The active capture session |
| `previewLayer` | `AVCaptureVideoPreviewLayer!` | The camera preview layer |

#### Methods

| Method | Description |
|---|---|
| `toggleTorch(on: Bool)` | Turn torch on/off |
| `flipCamera()` | Switch front ↔ back camera |
| `openGalleryScanner()` | Present `PHPickerViewController` |
| `resumeSession()` | Resume scanning after a result |

#### UIKit Usage

```swift
import UIKit
import QRCodeScanner

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func openScannerTapped(_ sender: UIButton) {
        let scannerVC        = QRScannerViewController()
        scannerVC.modalPresentationStyle = .fullScreen

        scannerVC.onScan = { [weak self] value in
            self?.dismiss(animated: true)
            print("Scanned: \(value)")
        }

        present(scannerVC, animated: true)
    }
}
```

---

## 🎯 Supported Code Types

| Code Type | Example |
|---|---|
| QR Code | URLs, text, contacts |
| EAN-13 | Retail product barcodes |
| EAN-8 | Small product barcodes |
| Code 128 | Shipping / logistics |
| Code 39 | Industrial barcodes |
| PDF417 | ID cards, boarding passes |
| Aztec | Transport tickets |
| Data Matrix | Electronics, healthcare |
| UPC-E | Compressed retail barcodes |

---

## 🧵 Concurrency Model (Swift 6 Safe)

```
AVFoundation (Background Thread)
    └── metadataOutput delegate fires
          └── nonisolated func metadataOutput(...)
                └── Task { @MainActor in }
                      └── UI updates / onScan callback ✅

itemProvider.loadObject (Background Thread)
    └── nonisolated func detectCodes(...)
          └── VNDetectBarcodesRequest
                └── handler.perform([request]) ← no actor crossing ✅
                      └── Task { @MainActor in }
                            └── onScan callback ✅

sessionQueue.async (Background Thread)
    └── nonisolated func bestCamera(for:) ← safe ✅
    └── captureSession.beginConfiguration()
    └── captureSession.commitConfiguration()
    └── Task { @MainActor in }
          └── previewLayer updates ✅
```

---

## 🗂️ Package Structure

```
QRScannerKit/
├── Package.swift
└── Sources/
    └── QRCodeScanner/
        ├── Components/
        │   ├── CornerBracket.swift          # L-shaped corner bracket Shape
        │   └── ScanningIndicator.swift      # Animated "Scanning ●●●" label
        ├── Service/
        │   └── QRScannerViewController.swift # AVFoundation + Vision engine
        └── Ui/
            ├── ScannerContainerView.swift   # ← Public main entry point
            ├── ScannerOverlay.swift         # ← Public overlay UI
            └── QRScannerView.swift          # ← Public UIViewControllerRepresentable
```

---

## ❓ Troubleshooting

<details>
<summary><strong>App crashes immediately on device</strong></summary>

Add these keys to `Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>Required to scan QR codes.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Required to scan codes from photos.</string>
```
</details>

<details>
<summary><strong>Black screen / no camera preview</strong></summary>

- Test on a **real device** — camera does not work in Simulator
- Ensure camera permission is granted in `Settings → Privacy → Camera`
- Call `resumeSession()` if you dismissed and re-presented the scanner
</details>

<details>
<summary><strong>EXC_BREAKPOINT crash on `handler.perform`</strong></summary>

This is a Swift 6 actor isolation issue. Ensure `detectCodes(in:orientation:)` is marked `nonisolated`. See [Swift 6 Concurrency Model](#-concurrency-model-swift-6-safe) above.
</details>

<details>
<summary><strong>Gallery scan returns "No Code Found"</strong></summary>

- Ensure the image is clear and well-lit
- QR code must be fully visible with no cropping
- Try a higher resolution photo
- The `Vision` framework requires clear, unobstructed codes
</details>

<details>
<summary><strong>Torch not working after camera flip</strong></summary>

Front camera has no torch. `toggleTorch(on:)` automatically ignores calls when the front camera is active.
</details>

---

## 📄 License

```
MIT License

Copyright (c) 2026 Karun Kumar

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
```

---

## 👨‍💻 Author

**Karun Kumar**
- GitHub: [@karun02525](https://github.com/karun02525)
- Package: [QRScannerKit](https://github.com/karun02525/QRScannerKit)

---

<p align="center">
  If this package helped you, please ⭐ star the repo!<br/>
  <a href="https://github.com/karun02525/QRScannerKit">github.com/karun02525/QRScannerKit</a>
</p>
