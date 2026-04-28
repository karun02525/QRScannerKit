//
//  ScannerOverlay.swift
//  QRCodeScanner
//
//  Created by KARUN KUMAR on 25/04/26.
//

import SwiftUI

// MARK: ════════════════════════════════════════════════════════
// MARK:  ScannerOverlay  –  Professional Camera Scanner UI
// MARK: ════════════════════════════════════════════════════════

public struct ScannerOverlay: View {
     var backAction:    () -> Void
     var helpAction:    () -> Void
     var torchAction:   (Bool) -> Void
     var flipAction:    () -> Void
     var galleryAction: () -> Void

    public init(
        backAction:    @escaping () -> Void,
        helpAction:    @escaping () -> Void,
        torchAction:   @escaping (Bool) -> Void,
        flipAction:    @escaping () -> Void    = {},
        galleryAction: @escaping () -> Void    = {}   // ✅ NEW
    ) {
        self.backAction    = backAction
        self.helpAction    = helpAction
        self.torchAction   = torchAction
        self.flipAction    = flipAction
        self.galleryAction = galleryAction
    }

    // ── UI State ─────────────────────────────────────────────
    @State private var isTorchOn = false
    @State private var flipDeg:  Double = 0

    // ── Animation State ───────────────────────────────────────
    @State private var laserY:      CGFloat = -124
    @State private var cornerGlow:  CGFloat = 3.0
    @State private var cornerScale: CGFloat = 1.0
    @State private var hintAlpha:   Double  = 0.55

    // ── Gallery Button Pulse ──────────────────────────────────
    @State private var galleryPulse: CGFloat = 1.0  // ✅ NEW subtle scale pulse

    // ── Design Tokens ─────────────────────────────────────────
    private let boxSize:      CGFloat = 260
    private let cornerLength: CGFloat = 30
    private let cornerStroke: CGFloat = 4.0
    private let accent = Color(red: 0.14, green: 0.93, blue: 0.54)

    // ─────────────────────────────────────────────────────────
    // MARK: Body
    // ─────────────────────────────────────────────────────────
    public var body: some View {
        GeometryReader { geo in
            let W = geo.size.width
            let H = geo.size.height

            ZStack {

                // ╔══════════════════════════════════════════╗
                // ║  LAYER 1 – Dimmed overlay + clear cutout ║
                // ╚══════════════════════════════════════════╝
                ZStack {
                    Color.black.opacity(0.72)

                    RoundedRectangle(cornerRadius: 22)
                        .frame(width: boxSize, height: boxSize)
                        .blendMode(.destinationOut)
                }
                .compositingGroup()

                // ╔══════════════════════════════════════════╗
                // ║  LAYER 2 – Ambient glow halo              ║
                // ╚══════════════════════════════════════════╝
                RoundedRectangle(cornerRadius: 22)
                    .stroke(accent.opacity(0.22), lineWidth: 2)
                    .blur(radius: 6)
                    .frame(width: boxSize + 14, height: boxSize + 14)
                    .position(x: W / 2, y: H / 2)

                // ╔══════════════════════════════════════════╗
                // ║  LAYER 3 – Animated corner brackets       ║
                // ╚══════════════════════════════════════════╝
                ForEach(CornerBracket.Position.allCases, id: \.self) { pos in
                    CornerBracket(position: pos, length: cornerLength)
                        .stroke(
                            accent,
                            style: StrokeStyle(
                                lineWidth: cornerStroke,
                                lineCap:   .round,
                                lineJoin:  .round
                            )
                        )
                        .shadow(color: accent.opacity(0.9), radius: cornerGlow)
                        .frame(width: boxSize, height: boxSize)
                        .scaleEffect(cornerScale)
                        .position(x: W / 2, y: H / 2)
                }

                // ╔══════════════════════════════════════════╗
                // ║  LAYER 4 – Laser scan line (clipped)      ║
                // ╚══════════════════════════════════════════╝
                ZStack {
                    // Wide soft glow beam
                    Capsule()
                        .fill(accent.opacity(0.36))
                        .frame(width: boxSize - 28, height: 20)
                        .blur(radius: 10)

                    // Sharp bright centre line
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    .clear,
                                    accent.opacity(0.72),
                                    .white,
                                    accent.opacity(0.72),
                                    .clear
                                ],
                                startPoint: .leading,
                                endPoint:   .trailing
                            )
                        )
                        .frame(width: boxSize - 28, height: 2.5)
                }
                .offset(y: laserY)
                .frame(width: boxSize, height: boxSize)
                .clipped()
                .position(x: W / 2, y: H / 2)

                // ╔══════════════════════════════════════════╗
                // ║  LAYER 5 – Top navigation bar             ║
                // ╚══════════════════════════════════════════╝
                VStack(spacing: 0) {
                    HStack {
                        // ← Back
                        navButton(icon: "arrow.left") { backAction() }
                            .padding(.leading, 20)

                        Spacer()

                        Text("Scan Code")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)

                        Spacer()

                        // ? Help
                        navButton(icon: "questionmark") { helpAction() }
                            .padding(.trailing, 20)
                    }
                    .padding(.top, 56)

                    Spacer()
                }

                // ╔══════════════════════════════════════════╗
                // ║  LAYER 6 – Hint text + scanning status    ║
                // ╚══════════════════════════════════════════╝
                VStack(spacing: 12) {
                    Text("Align QR code or barcode within the frame")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundStyle(.white.opacity(hintAlpha))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 44)

                    ScanningIndicator()
                }
                .position(x: W / 2, y: H / 2 + boxSize / 2 + 54)
                .allowsHitTesting(false)

                // ╔══════════════════════════════════════════╗
                // ║  LAYER 7 – Bottom frosted-glass control   ║
                // ╚══════════════════════════════════════════╝
                VStack {
                    Spacer()

                    // ── Divider line ──────────────────────
                    Rectangle()
                        .fill(.white.opacity(0.08))
                        .frame(height: 1)

                    HStack(spacing: 0) {

                        // 🔦  Torch toggle
                        bottomButton(
                            icon:     isTorchOn
                                        ? "flashlight.on.fill"
                                        : "flashlight.off.fill",
                            label:    isTorchOn ? "On" : "Torch",
                            tint:     isTorchOn ? .yellow : .white,
                            isActive: isTorchOn
                        ) {
                            isTorchOn.toggle()
                            torchAction(isTorchOn)
                        }
                        .frame(maxWidth: .infinity)

                        // ── Vertical divider ──────────────
                        Rectangle()
                            .fill(.white.opacity(0.10))
                            .frame(width: 1, height: 64)

                        // 🔄  Flip camera
                        bottomButton(
                            icon:         "arrow.triangle.2.circlepath.camera.fill",
                            label:        "Flip",
                            tint:         .white,
                            isActive:     false,
                            iconRotation: flipDeg
                        ) {
                            withAnimation(
                                .spring(response: 0.45, dampingFraction: 0.65)
                            ) {
                                flipDeg += 180
                            }
                            flipAction()
                        }
                        .frame(maxWidth: .infinity)

                        // ── Vertical divider ──────────────
                        Rectangle()
                            .fill(.white.opacity(0.10))
                            .frame(width: 1, height: 64)

                        // 🖼️  Gallery  ✅ NEW
                        bottomButton(
                            icon:     "photo.on.rectangle.angled",
                            label:    "Gallery",
                            tint:     .white,
                            isActive: false,
                            scale:    galleryPulse
                        ) {
                            // Brief pop animation on tap
                            withAnimation(
                                .spring(response: 0.3, dampingFraction: 0.5)
                            ) {
                                galleryPulse = 1.18
                            }
                            // Snap back
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                                withAnimation(
                                    .spring(response: 0.3, dampingFraction: 0.6)
                                ) {
                                    galleryPulse = 1.0
                                }
                            }
                            galleryAction()
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 36)
                }
            }
            .onAppear { startAnimations() }
        }
        .ignoresSafeArea()
    }

    // ─────────────────────────────────────────────────────────
    // MARK: – Sub-views
    // ─────────────────────────────────────────────────────────

    /// Small circular button used in the top nav bar
    @ViewBuilder
    private func navButton(
        icon:   String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }

    /// Labelled circular button used in the bottom control bar
    /// `scale` param added for gallery pop animation ✅
    @ViewBuilder
    private func bottomButton(
        icon:         String,
        label:        String,
        tint:         Color,
        isActive:     Bool,
        iconRotation: Double  = 0,
        scale:        CGFloat = 1.0,   // ✅ NEW param
        action:       @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    // Background fill
                    Circle()
                        .fill(tint.opacity(isActive ? 0.22 : 0.12))

                    // Subtle border ring
                    Circle()
                        .stroke(tint.opacity(0.30), lineWidth: 1)

                    // Icon
                    Image(systemName: icon)
                        .font(.system(size: 23, weight: .medium))
                        .foregroundStyle(tint)
                        .rotationEffect(.degrees(iconRotation))
                }
                .frame(width: 62, height: 62)
                .scaleEffect(scale)          // ✅ drives gallery pop
                .shadow(
                    color:  isActive ? tint.opacity(0.55) : .clear,
                    radius: 12
                )
                .animation(.easeInOut(duration: 0.25), value: isActive)

                Text(label)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.65))
            }
        }
        .buttonStyle(.plain)
    }

    // ─────────────────────────────────────────────────────────
    // MARK: – Animation Triggers
    // ─────────────────────────────────────────────────────────

    private func startAnimations() {

        // ① Laser sweep  -124 ↔ +124
        withAnimation(
            .linear(duration: 2.2)
            .repeatForever(autoreverses: true)
        ) {
            laserY = 124
        }

        // ② Corner bracket glow + breath scale
        withAnimation(
            .easeInOut(duration: 1.5)
            .repeatForever(autoreverses: true)
        ) {
            cornerGlow  = 12
            cornerScale = 1.016
        }

        // ③ Hint text opacity breathing
        withAnimation(
            .easeInOut(duration: 2.0)
            .repeatForever(autoreverses: true)
        ) {
            hintAlpha = 1.0
        }
    }
}

// MARK: - Preview ──────────────────────────────────────────────
#Preview {
    ZStack {
        LinearGradient(
            colors: [Color(white: 0.18), Color(white: 0.06)],
            startPoint: .top,
            endPoint:   .bottom
        )
        .ignoresSafeArea()

        ScannerOverlay(
            backAction:    { print("← Back")          },
            helpAction:    { print("? Help")           },
            torchAction:   { print("Torch: \($0)")     },
            flipAction:    { print("📷 Flip")          },
            galleryAction: { print("🖼️ Gallery tapped") }  // ✅ NEW
        )
    }
}
