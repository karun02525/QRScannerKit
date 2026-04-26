//
//  CornerBracket.swift
//  QRCodeScanner
//
//  Created by KARUN KUMAR on 25/04/26.
//


import SwiftUI

// MARK: - L-shaped Corner Bracket Shape
struct CornerBracket: Shape {

    enum Position: CaseIterable {
        case topLeft, topRight, bottomLeft, bottomRight
    }

    let position: Position
    let length: CGFloat          // arm length of each bracket leg

    func path(in rect: CGRect) -> Path {
        var p = Path()
        switch position {

        case .topLeft:
            p.move(to:    CGPoint(x: rect.minX,          y: rect.minY + length))
            p.addLine(to: CGPoint(x: rect.minX,          y: rect.minY         ))
            p.addLine(to: CGPoint(x: rect.minX + length, y: rect.minY         ))

        case .topRight:
            p.move(to:    CGPoint(x: rect.maxX - length, y: rect.minY         ))
            p.addLine(to: CGPoint(x: rect.maxX,          y: rect.minY         ))
            p.addLine(to: CGPoint(x: rect.maxX,          y: rect.minY + length))

        case .bottomLeft:
            p.move(to:    CGPoint(x: rect.minX,          y: rect.maxY - length))
            p.addLine(to: CGPoint(x: rect.minX,          y: rect.maxY         ))
            p.addLine(to: CGPoint(x: rect.minX + length, y: rect.maxY         ))

        case .bottomRight:
            p.move(to:    CGPoint(x: rect.maxX - length, y: rect.maxY         ))
            p.addLine(to: CGPoint(x: rect.maxX,          y: rect.maxY         ))
            p.addLine(to: CGPoint(x: rect.maxX,          y: rect.maxY - length))
        }
        return p
    }
}