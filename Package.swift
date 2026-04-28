// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QRCodeScanner",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(
            name: "QRCodeScanner",
            targets: ["QRCodeScanner"] // This MUST match the name in targets below
        ),
    ],
    targets: [
        .target(
            name: "QRCodeScanner",
            dependencies: [],
            path: "Sources/QRCodeScanner" // Optional: helps SPM find your files
        ),
    ],
    swiftLanguageModes: [.v6]
)
