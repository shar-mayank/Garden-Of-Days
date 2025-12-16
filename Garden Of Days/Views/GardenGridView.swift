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
    private let growthModeColumns = Array(repeating: GridItem(.flexible(), spacing: -12), count: 12)  // Tighter grid for garden overlap

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
        LazyVGrid(columns: growthModeColumns, spacing: -10) {  // Negative spacing for row overlap
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

    /// Dot color based on day status
    private var dotColor: Color {
        if isToday {
            return .white
        } else if day.isPast {
            return .white  // Past days are white
        } else {
            return Color.white.opacity(0.25)  // Future days are dim
        }
    }

    var body: some View {
        ZStack {
            // Glow effect for today
            if isToday {
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: dotSize + 12, height: dotSize + 12)
                    .blur(radius: 6)
                    .scaleEffect(isAnimating ? 1.3 : 1.0)
            }

            if day.hasMemory {
                // Filled dot (has memory)
                Circle()
                    .fill(Color.white)
                    .frame(width: filledDotSize, height: filledDotSize)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
            } else {
                // Empty dot - white for past, dim for future
                Circle()
                    .fill(dotColor)
                    .frame(width: dotSize, height: dotSize)
            }

            // Today indicator ring
            if isToday {
                Circle()
                    .stroke(Color.white.opacity(0.6), lineWidth: 1.5)
                    .frame(width: dotSize + 8, height: dotSize + 8)
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

    @State private var scale: CGFloat = 0.8

    private let doodleManager = DoodleManager.shared

    // Flower size - larger for visual overlap
    private let flowerSize: CGFloat = 50
    private let cellSize: CGFloat = 28

    // Small random offset for organic feel (but contained)
    private var randomOffset: CGSize {
        let seed = day.id
        let x = CGFloat(sin(Double(seed) * 0.3)) * 3
        let y = CGFloat(cos(Double(seed) * 0.4)) * 3
        return CGSize(width: x, height: y)
    }

    // Slight random rotation for variety
    private var randomRotation: Double {
        let variation = Double(day.id % 20) - 10  // -10 to +10 degrees
        return variation
    }

    private var randomScale: CGFloat {
        let base = 0.85
        let variation = Double(day.id % 10) * 0.03
        return CGFloat(base + variation)
    }

    var body: some View {
        ZStack {
            // Invisible tap target - always tappable at cell size
            Rectangle()
                .fill(Color.clear)
                .frame(width: cellSize, height: cellSize)

            if day.hasMemory, let memory = day.memory {
                // Show flower doodle - visual only, taps pass through
                flowerDoodle(assetName: memory.doodleAssetName)
                    .frame(width: flowerSize, height: flowerSize)
                    .scaleEffect(randomScale * scale)
                    .rotationEffect(.degrees(randomRotation))
                    .offset(randomOffset)
                    .allowsHitTesting(false)  // Taps pass through to the cell below
            } else {
                // Placeholder dot for empty days
                Circle()
                    .fill(color.opacity(0.35))
                    .frame(width: 6, height: 6)
            }
        }
        .frame(width: cellSize, height: cellSize)
        .contentShape(Rectangle())  // Tap area is exactly the cell
        .onAppear {
            if day.hasMemory {
                withAnimation(.easeOut(duration: 0.5).delay(Double(day.id) * 0.002)) {
                    scale = 1.0
                }
            }
        }
    }

    @ViewBuilder
    private func flowerDoodle(assetName: String) -> some View {
        // PNG floral images
        Image(assetName)
            .resizable()
            .aspectRatio(contentMode: .fit)
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
