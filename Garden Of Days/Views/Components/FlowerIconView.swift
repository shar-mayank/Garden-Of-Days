//
//  FlowerIconView.swift
//  Garden Of Days
//
//  Created by Mayank Sharma on 15/12/25.
//

import SwiftUI

/// A decorative flower icon view with animation
struct FlowerIconView: View {
    let color: Color
    let size: CGFloat
    var isAnimated: Bool = false

    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Outer petals
            ForEach(0..<6, id: \.self) { index in
                Petal()
                    .stroke(color, lineWidth: 1.5)
                    .frame(width: size * 0.4, height: size * 0.6)
                    .offset(y: -size * 0.2)
                    .rotationEffect(.degrees(Double(index) * 60))
            }

            // Center circle
            Circle()
                .fill(color)
                .frame(width: size * 0.2, height: size * 0.2)
        }
        .frame(width: size, height: size)
        .rotationEffect(.degrees(rotation))
        .scaleEffect(scale)
        .onAppear {
            if isAnimated {
                withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                    rotation = 15
                }
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    scale = 1.05
                }
            }
        }
    }
}

/// A single petal shape
struct Petal: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))

        path.addQuadCurve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            control: CGPoint(x: rect.maxX, y: rect.midY)
        )

        path.addQuadCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            control: CGPoint(x: rect.minX, y: rect.midY)
        )

        return path
    }
}

/// A simple leaf shape
struct LeafShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))

        // Right curve
        path.addQuadCurve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            control: CGPoint(x: rect.maxX, y: rect.midY - rect.height * 0.1)
        )

        // Left curve
        path.addQuadCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            control: CGPoint(x: rect.minX, y: rect.midY - rect.height * 0.1)
        )

        // Center vein
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))

        return path
    }
}

/// A decorative branch with leaves
struct BranchView: View {
    let color: Color
    let length: CGFloat

    var body: some View {
        ZStack {
            // Main branch
            Path { path in
                path.move(to: CGPoint(x: 0, y: length))
                path.addCurve(
                    to: CGPoint(x: length * 0.8, y: 0),
                    control1: CGPoint(x: length * 0.2, y: length * 0.7),
                    control2: CGPoint(x: length * 0.5, y: length * 0.3)
                )
            }
            .stroke(color, lineWidth: 1.5)

            // Leaves along branch
            ForEach(0..<4, id: \.self) { index in
                LeafShape()
                    .stroke(color, lineWidth: 1)
                    .frame(width: 10, height: 16)
                    .rotationEffect(.degrees(index % 2 == 0 ? -30 : 30))
                    .offset(
                        x: CGFloat(index) * length * 0.2,
                        y: length - CGFloat(index) * length * 0.25
                    )
            }
        }
        .frame(width: length, height: length)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 40) {
        FlowerIconView(color: Color(hex: "f670b2"), size: 60, isAnimated: true)

        FlowerIconView(color: .black, size: 40)

        LeafShape()
            .stroke(Color(hex: "f670b2"), lineWidth: 1.5)
            .frame(width: 30, height: 50)

        BranchView(color: Color(hex: "f670b2"), length: 80)
    }
    .padding()
}
