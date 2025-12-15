//
//  GardenGridView.swift
//  Garden Of Days
//
//  Created by Mayank Sharma on 15/12/25.
//

import SwiftUI

struct GardenGridView: View {
    @Bindable var viewModel: GardenViewModel

    // Grid configuration
    private let voidModeColumns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 20)
    private let growthModeColumns = Array(repeating: GridItem(.flexible(), spacing: -8), count: 14)

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                if viewModel.viewMode == .void {
                    voidModeGrid
                        .padding(.horizontal, 12)
                        .padding(.vertical, 20)
                } else {
                    growthModeGrid
                        .padding(.horizontal, 8)
                        .padding(.vertical, 16)
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    // MARK: - Void Mode (Dark, Minimalist Dots)

    private var voidModeGrid: some View {
        LazyVGrid(columns: voidModeColumns, spacing: 8) {
            ForEach(viewModel.gardenDays) { day in
                VoidDotView(
                    day: day,
                    isToday: day.id == viewModel.todayDayOfYear
                )
                .onTapGesture {
                    viewModel.selectDay(day)
                }
            }
        }
        .transition(.opacity)
    }

    // MARK: - Growth Mode (Light, Organic Flowers)

    private var growthModeGrid: some View {
        LazyVGrid(columns: growthModeColumns, spacing: -4) {
            ForEach(viewModel.gardenDays) { day in
                GrowthFlowerView(
                    day: day,
                    color: viewModel.primaryColor
                )
                .onTapGesture {
                    viewModel.selectDay(day)
                }
            }
        }
        .transition(.opacity)
    }
}

// MARK: - Void Mode Dot View

struct VoidDotView: View {
    let day: GardenDay
    let isToday: Bool

    @State private var isAnimating: Bool = false

    private let dotSize: CGFloat = 8
    private let filledDotSize: CGFloat = 10

    var body: some View {
        ZStack {
            if day.hasMemory {
                // Filled dot (has memory)
                Circle()
                    .fill(Color.white)
                    .frame(width: filledDotSize, height: filledDotSize)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
            } else {
                // Empty dot
                Circle()
                    .fill(Color.white.opacity(isToday ? 0.8 : 0.3))
                    .frame(width: dotSize, height: dotSize)
            }

            // Today indicator ring
            if isToday {
                Circle()
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    .frame(width: dotSize + 6, height: dotSize + 6)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
            }
        }
        .frame(width: 16, height: 16)
        .onAppear {
            if isToday {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
        }
    }
}

// MARK: - Growth Mode Flower View

struct GrowthFlowerView: View {
    let day: GardenDay
    let color: Color

    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0

    private let doodleManager = DoodleManager.shared

    // Random offsets for organic feel
    private var randomOffset: CGSize {
        let seed = day.id
        let x = CGFloat(sin(Double(seed) * 0.1)) * 4
        let y = CGFloat(cos(Double(seed) * 0.15)) * 4
        return CGSize(width: x, height: y)
    }

    private var randomRotation: Double {
        Double(day.id % 360) * 0.5 - 90
    }

    private var randomScale: CGFloat {
        let base = 0.8
        let variation = Double(day.id % 10) * 0.05
        return CGFloat(base + variation)
    }

    var body: some View {
        Group {
            if day.hasMemory, let memory = day.memory {
                // Show flower doodle
                flowerDoodle(assetName: memory.doodleAssetName)
                    .foregroundColor(color)
                    .frame(width: 28, height: 28)
                    .scaleEffect(randomScale * scale)
                    .rotationEffect(.degrees(randomRotation + rotation))
                    .offset(randomOffset)
            } else {
                // Faint placeholder dot
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 4, height: 4)
            }
        }
        .frame(width: 28, height: 28)
        .onAppear {
            // Subtle animation on appear
            if day.hasMemory {
                withAnimation(.easeOut(duration: 0.5).delay(Double(day.id) * 0.002)) {
                    scale = 1.0
                }
            }
        }
    }

    @ViewBuilder
    private func flowerDoodle(assetName: String) -> some View {
        if doodleManager.isImageAsset(assetName) {
            // Image asset from Assets.xcassets (your SVG/PDF files)
            Image(assetName)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
        } else if let pattern = FloralPattern(rawValue: assetName) {
            // Custom floral pattern (SwiftUI shapes)
            FloralDoodleView(pattern: pattern, size: 24, color: color)
        } else if let sfSymbol = doodleManager.getSFSymbol(assetName) {
            // SF Symbol
            Image(systemName: sfSymbol)
                .font(.system(size: 18, weight: .light))
        } else {
            // Fallback
            Image(systemName: "leaf.fill")
                .font(.system(size: 18, weight: .light))
        }
    }
}

// MARK: - Toast View

struct ToastView: View {
    let message: String
    let isVisible: Bool

    var body: some View {
        Text(message)
            .font(.system(.caption, design: .monospaced))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.8))
            )
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.8)
            .animation(.spring(duration: 0.3), value: isVisible)
    }
}

// MARK: - Preview

#Preview("Void Mode") {
    let viewModel = GardenViewModel()
    viewModel.viewMode = .void
    viewModel.loadGardenDays()

    return GardenGridView(viewModel: viewModel)
        .background(Color.black)
}

#Preview("Growth Mode") {
    let viewModel = GardenViewModel()
    viewModel.viewMode = .growth
    viewModel.loadGardenDays()

    return GardenGridView(viewModel: viewModel)
        .background(Color(hex: "E5E5EA"))
}
