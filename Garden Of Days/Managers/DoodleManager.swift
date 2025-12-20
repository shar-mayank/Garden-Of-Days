//
//  DoodleManager.swift
//  Garden Of Days
//
//  Created by Mayank Sharma on 15/12/25.
//

import Foundation
import SwiftUI

/// Manages the floral doodle assets for the garden visualization
final class DoodleManager {
    static let shared = DoodleManager()

    // MARK: - Image Assets from Assets.xcassets
    // 25 floral PNG images with transparent backgrounds
    private let imageAssets: [String] = [
        "floral_1", "floral_2", "floral_3", "floral_4", "floral_5",
        "floral_6", "floral_7", "floral_8", "floral_9", "floral_10",
        "floral_11", "floral_12", "floral_13", "floral_14", "floral_15",
        "floral_16", "floral_17", "floral_18", "floral_19", "floral_20",
        "floral_21", "floral_22", "floral_23", "floral_24", "floral_25"
    ]

    private init() {}

    /// Returns a random doodle asset name (only uses your SVG images)
    func getRandomDoodle() -> String {
        return imageAssets.randomElement() ?? "floral_1"
    }

    /// Returns all available doodle options
    func getAllDoodles() -> [String] {
        return imageAssets
    }

    /// Check if the doodle is a custom floral pattern (SwiftUI shape) - disabled
    func isCustomFloral(_ name: String) -> Bool {
        return false
    }

    /// Check if the doodle is an image asset from Assets.xcassets
    func isImageAsset(_ name: String) -> Bool {
        return imageAssets.contains(name)
    }

    /// Get SF Symbol name - disabled, we only use SVG images now
    func getSFSymbol(_ name: String) -> String? {
        return nil
    }
}

/// Custom floral patterns that will be drawn with SwiftUI paths
enum FloralPattern: String, CaseIterable {
    case flower1 = "floral.flower1"
    case flower2 = "floral.flower2"
    case flower3 = "floral.flower3"
    case flower4 = "floral.flower4"
    case flower5 = "floral.flower5"
    case branch1 = "floral.branch1"
    case branch2 = "floral.branch2"
    case vine1 = "floral.vine1"
    case vine2 = "floral.vine2"
    case bud1 = "floral.bud1"
}

// MARK: - Custom Floral Shape Views

struct FloralDoodleView: View {
    let pattern: FloralPattern
    let size: CGFloat
    let color: Color

    var body: some View {
        switch pattern {
        case .flower1:
            FlowerShape1()
                .stroke(color, lineWidth: 1.5)
                .frame(width: size, height: size)
        case .flower2:
            FlowerShape2()
                .stroke(color, lineWidth: 1.5)
                .frame(width: size, height: size)
        case .flower3:
            FlowerShape3()
                .stroke(color, lineWidth: 1.5)
                .frame(width: size, height: size)
        case .flower4:
            FlowerShape4()
                .stroke(color, lineWidth: 1.5)
                .frame(width: size, height: size)
        case .flower5:
            FlowerShape5()
                .stroke(color, lineWidth: 1.5)
                .frame(width: size, height: size)
        case .branch1:
            BranchShape1()
                .stroke(color, lineWidth: 1.5)
                .frame(width: size, height: size)
        case .branch2:
            BranchShape2()
                .stroke(color, lineWidth: 1.5)
                .frame(width: size, height: size)
        case .vine1:
            VineShape1()
                .stroke(color, lineWidth: 1.5)
                .frame(width: size, height: size)
        case .vine2:
            VineShape2()
                .stroke(color, lineWidth: 1.5)
                .frame(width: size, height: size)
        case .bud1:
            BudShape1()
                .stroke(color, lineWidth: 1.5)
                .frame(width: size, height: size)
        }
    }
}

// MARK: - Custom Shape Definitions

struct FlowerShape1: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let petalCount = 6
        let petalLength = min(rect.width, rect.height) * 0.4

        for i in 0..<petalCount {
            let angle = (CGFloat(i) / CGFloat(petalCount)) * 2 * .pi - .pi / 2
            let petalEnd = CGPoint(
                x: center.x + cos(angle) * petalLength,
                y: center.y + sin(angle) * petalLength
            )

            path.move(to: center)
            path.addQuadCurve(
                to: petalEnd,
                control: CGPoint(
                    x: center.x + cos(angle + 0.3) * petalLength * 0.8,
                    y: center.y + sin(angle + 0.3) * petalLength * 0.8
                )
            )
        }

        // Center circle
        path.addEllipse(in: CGRect(x: center.x - 4, y: center.y - 4, width: 8, height: 8))

        return path
    }
}

struct FlowerShape2: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) * 0.35
        let petalCount = 5

        for i in 0..<petalCount {
            let angle = (CGFloat(i) / CGFloat(petalCount)) * 2 * .pi - .pi / 2
            let nextAngle = (CGFloat(i + 1) / CGFloat(petalCount)) * 2 * .pi - .pi / 2

            let start = CGPoint(
                x: center.x + cos(angle) * radius * 0.3,
                y: center.y + sin(angle) * radius * 0.3
            )
            let end = CGPoint(
                x: center.x + cos(nextAngle) * radius * 0.3,
                y: center.y + sin(nextAngle) * radius * 0.3
            )
            let control = CGPoint(
                x: center.x + cos((angle + nextAngle) / 2) * radius,
                y: center.y + sin((angle + nextAngle) / 2) * radius
            )

            path.move(to: start)
            path.addQuadCurve(to: end, control: control)
        }

        return path
    }
}

struct FlowerShape3: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) * 0.4

        // Draw a daisy-like flower
        for i in 0..<8 {
            let angle = (CGFloat(i) / 8) * 2 * .pi
            path.move(to: center)

            let endPoint = CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )

            // Curved petal
            path.addCurve(
                to: endPoint,
                control1: CGPoint(
                    x: center.x + cos(angle - 0.2) * radius * 0.5,
                    y: center.y + sin(angle - 0.2) * radius * 0.5
                ),
                control2: CGPoint(
                    x: center.x + cos(angle + 0.2) * radius * 0.8,
                    y: center.y + sin(angle + 0.2) * radius * 0.8
                )
            )
        }

        return path
    }
}

struct FlowerShape4: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) * 0.4
        let innerRadius = outerRadius * 0.4

        // Star flower
        for i in 0..<10 {
            let angle = (CGFloat(i) / 10) * 2 * .pi - .pi / 2
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let point = CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )

            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()

        return path
    }
}

struct FlowerShape5: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) * 0.35

        // Spiral flower
        for i in stride(from: 0, to: 720, by: 30) {
            let angle = CGFloat(i) * .pi / 180
            let r = radius * (1 - CGFloat(i) / 1440)
            let point = CGPoint(
                x: center.x + cos(angle) * r,
                y: center.y + sin(angle) * r
            )

            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }

        return path
    }
}

struct BranchShape1: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let startX = rect.minX + rect.width * 0.2
        let endX = rect.maxX - rect.width * 0.2

        // Main stem
        path.move(to: CGPoint(x: startX, y: rect.midY))
        path.addLine(to: CGPoint(x: endX, y: rect.midY))

        // Leaves
        let leafPoints: [(CGFloat, Bool)] = [(0.3, true), (0.45, false), (0.6, true), (0.75, false)]
        for (progress, isTop) in leafPoints {
            let x = startX + (endX - startX) * progress
            let y = rect.midY
            let leafSize: CGFloat = 12

            path.move(to: CGPoint(x: x, y: y))
            if isTop {
                path.addQuadCurve(
                    to: CGPoint(x: x + 8, y: y - leafSize),
                    control: CGPoint(x: x + 12, y: y - 4)
                )
            } else {
                path.addQuadCurve(
                    to: CGPoint(x: x + 8, y: y + leafSize),
                    control: CGPoint(x: x + 12, y: y + 4)
                )
            }
        }

        return path
    }
}

struct BranchShape2: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)

        // Y-shaped branch
        path.move(to: CGPoint(x: center.x, y: rect.maxY - 8))
        path.addLine(to: center)

        // Left branch
        path.move(to: center)
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + 10, y: rect.minY + 10),
            control: CGPoint(x: center.x - 15, y: center.y - 10)
        )

        // Right branch
        path.move(to: center)
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - 10, y: rect.minY + 10),
            control: CGPoint(x: center.x + 15, y: center.y - 10)
        )

        return path
    }
}

struct VineShape1: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Curvy vine
        path.move(to: CGPoint(x: rect.minX + 5, y: rect.midY))
        path.addCurve(
            to: CGPoint(x: rect.maxX - 5, y: rect.midY),
            control1: CGPoint(x: rect.midX - 10, y: rect.minY + 5),
            control2: CGPoint(x: rect.midX + 10, y: rect.maxY - 5)
        )

        // Small curls
        let curlPositions: [CGFloat] = [0.25, 0.5, 0.75]
        for pos in curlPositions {
            let x = rect.minX + rect.width * pos
            path.move(to: CGPoint(x: x, y: rect.midY))
            path.addArc(
                center: CGPoint(x: x + 4, y: rect.midY),
                radius: 4,
                startAngle: .degrees(180),
                endAngle: .degrees(0),
                clockwise: false
            )
        }

        return path
    }
}

struct VineShape2: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)

        // Spiral vine
        var angle: CGFloat = 0
        var radius: CGFloat = 5
        let startPoint = CGPoint(x: center.x + radius, y: center.y)
        path.move(to: startPoint)

        while radius < min(rect.width, rect.height) * 0.4 {
            angle += 0.3
            radius += 0.8
            let point = CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )
            path.addLine(to: point)
        }

        return path
    }
}

struct BudShape1: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)

        // Stem
        path.move(to: CGPoint(x: center.x, y: rect.maxY - 5))
        path.addLine(to: CGPoint(x: center.x, y: center.y + 5))

        // Bud
        path.addEllipse(in: CGRect(
            x: center.x - 8,
            y: center.y - 10,
            width: 16,
            height: 20
        ))

        // Small leaves at base
        path.move(to: CGPoint(x: center.x, y: center.y + 5))
        path.addQuadCurve(
            to: CGPoint(x: center.x - 10, y: center.y + 12),
            control: CGPoint(x: center.x - 8, y: center.y + 5)
        )

        path.move(to: CGPoint(x: center.x, y: center.y + 5))
        path.addQuadCurve(
            to: CGPoint(x: center.x + 10, y: center.y + 12),
            control: CGPoint(x: center.x + 8, y: center.y + 5)
        )

        return path
    }
}
