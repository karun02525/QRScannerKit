import Foundation
import SwiftUI

struct ScannerOverlay: View {
    
    @State private var isTorchOn = false
    var backAction: () -> Void
    var helpAction: () -> Void
    var torchAction: (Bool) -> Void

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let boxSize: CGFloat = 250
            
            // 1. The Masked Background
            ZStack {
                Color.black.opacity(0.5)
                
                RoundedRectangle(cornerRadius: 16)
                    .frame(width: boxSize, height: boxSize)
                    .blendMode(.destinationOut)
            }
            .compositingGroup()
            
            // 2. The Scanner Frame (Outline)
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white, lineWidth: 3)
                .frame(width: boxSize, height: boxSize)
                .position(x: size.width / 2, y: size.height / 2)
            
            // 3. Top Toolbar (Back and Help)
            HStack {
                Button(action: { backAction() }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                        .padding()
                }
                .padding(.top, 50)
                .padding(.leading, 10)
                
                Spacer()
                
                Button(action: { helpAction() }) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                        .padding()
                }
                .padding(.top, 50)
                .padding(.trailing, 10)
            }
            
            // 4. Torch Button (Positioned at bottom)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        isTorchOn.toggle() // Update local UI state
                        torchAction(isTorchOn) // Pass new state to parent
                    }) {
                        Image(systemName: isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .padding(20)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .foregroundStyle(isTorchOn ? .yellow : .white)
                    }
                    Spacer()
                }
                .padding(.bottom, 60)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ScannerOverlay(
        backAction: { print("Back Pressed") },
        helpAction: { print("Help Pressed") },
        torchAction: { isOn in print("Torch is \(isOn)") }
    )
}
