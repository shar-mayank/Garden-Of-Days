//
//  GardenGridView.swift
//  Garden Of Days
//
//  Created by Mayank Sharma on 15/12/25.
//

import SwiftUI
import SwiftData

struct GardenGridView: View {
    @Bindable var viewModel: GardenViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let isLandscape = geometry.size.width > geometry.size.height
            let gridConfig = GridConfig(screenWidth: screenWidth, isLandscape: isLandscape, sizeClass: horizontalSizeClass)

            ScrollView {
                if viewModel.viewMode == .void {
                    voidModeGrid(config: gridConfig)
                        .padding(.horizontal, gridConfig.horizontalPadding)
                        .padding(.vertical, 20)
                } else {
                    growthModeGrid(config: gridConfig)
                        .padding(.horizontal, gridConfig.horizontalPadding)
                        .padding(.vertical, 16)
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    // MARK: - Void Mode (Dark, Minimalist Dots)

    private func voidModeGrid(config: GridConfig) -> some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: config.voidSpacing), count: config.voidColumns)

        return LazyVGrid(columns: columns, spacing: config.voidSpacing) {
            ForEach(viewModel.gardenDays) { day in
                VoidDotView(
                    day: day,
                    isToday: day.id == viewModel.todayDayOfYear,
                    config: config
                )
                .onTapGesture {
                    viewModel.selectDay(day)
                }
            }
        }
        .transition(.opacity)
    }

    // MARK: - Growth Mode (Light, Organic Flowers)

    private func growthModeGrid(config: GridConfig) -> some View {
        let columns = Array(repeating: GridItem(.fixed(config.cellSize), spacing: 0), count: config.growthColumns)

        return LazyVGrid(columns: columns, spacing: 0) {
            ForEach(viewModel.gardenDays) { day in
                GrowthFlowerView(
                    day: day,
                    color: viewModel.primaryColor,
                    config: config
                )
                .onTapGesture {
                    viewModel.selectDay(day)
                }
            }
        }
        .transition(.opacity)
    }
}

// MARK: - Dynamic Grid Configuration

struct GridConfig {
    let screenWidth: CGFloat
    let isLandscape: Bool
    let sizeClass: UserInterfaceSizeClass?

    var isIPad: Bool {
        sizeClass == .regular
    }

    // Scale factor based on device
    var scaleFactor: CGFloat {
        if isIPad {
            return isLandscape ? 2.0 : 1.8
        } else {
            return isLandscape ? 1.3 : 1.0
        }
    }

    // Growth mode (pink side)
    var cellSize: CGFloat {
        let base: CGFloat = 18
        return base * scaleFactor
    }

    var flowerSize: CGFloat {
        let base: CGFloat = 45
        return base * scaleFactor
    }

    var dotSize: CGFloat {
        let base: CGFloat = 4
        return base * scaleFactor
    }

    var growthColumns: Int {
        if isIPad {
            return isLandscape ? 28 : 20
        } else {
            return isLandscape ? 28 : 18
        }
    }

    // Void mode (dark side)
    var voidColumns: Int {
        if isIPad {
            return isLandscape ? 32 : 24
        } else {
            return isLandscape ? 28 : 20
        }
    }

    var voidSpacing: CGFloat {
        isIPad ? 12 : 8
    }

    var voidDotSize: CGFloat {
        let base: CGFloat = 8
        return base * scaleFactor
    }

    var voidFilledDotSize: CGFloat {
        let base: CGFloat = 10
        return base * scaleFactor
    }

    var horizontalPadding: CGFloat {
        isIPad ? 24 : 8
    }
}

// MARK: - Void Mode Dot View

struct VoidDotView: View {
    let day: GardenDay
    let isToday: Bool
    let config: GridConfig

    @State private var isAnimating: Bool = false

    private var dotSize: CGFloat { config.voidDotSize }
    private var filledDotSize: CGFloat { config.voidFilledDotSize }

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
                    .stroke(Color.white.opacity(0.6), lineWidth: 1.5 * config.scaleFactor)
                    .frame(width: dotSize + 8, height: dotSize + 8)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
            }
        }
        .frame(width: dotSize * 2, height: dotSize * 2)
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
    let config: GridConfig

    @State private var scale: CGFloat = 0.8

    private let doodleManager = DoodleManager.shared

    private var flowerSize: CGFloat { config.flowerSize }
    private var cellSize: CGFloat { config.cellSize }
    private var dotSize: CGFloat { config.dotSize }

    // Small random offset for organic feel (scaled)
    private var randomOffset: CGSize {
        let seed = day.id
        let offsetScale = config.scaleFactor * 3
        let x = CGFloat(sin(Double(seed) * 0.3)) * offsetScale
        let y = CGFloat(cos(Double(seed) * 0.4)) * offsetScale
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
            // Invisible tap target - always tappable
            Color.clear
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
                // Placeholder dot for empty days (increased opacity to 0.45)
                Circle()
                    .fill(color.opacity(0.45))
                    .frame(width: dotSize, height: dotSize)
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
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: MemoryEntry.self, configurations: config)

    let viewModel = GardenViewModel()
    viewModel.viewMode = .void
    viewModel.configure(with: container.mainContext)

    return GardenGridView(viewModel: viewModel)
        .background(Color.black)
        .modelContainer(container)
}

#Preview("Growth Mode") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: MemoryEntry.self, configurations: config)

    let viewModel = GardenViewModel()
    viewModel.viewMode = .growth
    viewModel.configure(with: container.mainContext)

    // Add some sample memories for preview
    let doodleManager = DoodleManager.shared
    for day in [1, 5, 10, 15, 20, 50, 100, 150, 200, 250, 300, 350] {
        if let date = Date.dateForDayOfYear(day, year: Calendar.current.component(.year, from: Date())) {
            let memory = MemoryEntry(date: date, content: "Sample memory", doodleAssetName: doodleManager.getRandomDoodle())
            container.mainContext.insert(memory)
        }
    }
    try? container.mainContext.save()
    viewModel.reloadMemories()

    return GardenGridView(viewModel: viewModel)
        .background(Color(hex: "E5E5EA"))
        .modelContainer(container)
}

#Preview("iPad Growth Mode", traits: .landscapeLeft) {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: MemoryEntry.self, configurations: config)

    let viewModel = GardenViewModel()
    viewModel.viewMode = .growth
    viewModel.configure(with: container.mainContext)

    return GardenGridView(viewModel: viewModel)
        .background(Color(hex: "E5E5EA"))
        .modelContainer(container)
}
