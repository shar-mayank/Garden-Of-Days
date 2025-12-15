//
//  StatsView.swift
//  Garden Of Days
//
//  Created by Mayank Sharma on 15/12/25.
//

import SwiftUI

/// A view showing garden statistics
struct StatsView: View {
    let viewModel: GardenViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(hex: "FAFAFA")
                .ignoresSafeArea()

            VStack(spacing: 32) {
                // Header
                HStack {
                    Text("your garden")
                        .font(.system(.title2, design: .monospaced))
                        .foregroundColor(Color(hex: "000080"))

                    Spacer()

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "000080"))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)

                // Stats cards
                VStack(spacing: 16) {
                    StatCard(
                        title: "memories planted",
                        value: "\(viewModel.memoriesCount)",
                        subtitle: "flowers blooming",
                        icon: "leaf.fill"
                    )

                    HStack(spacing: 16) {
                        StatCard(
                            title: "days passed",
                            value: "\(viewModel.todayDayOfYear)",
                            icon: "calendar"
                        )

                        StatCard(
                            title: "days left",
                            value: "\(viewModel.daysLeftInYear)",
                            icon: "hourglass"
                        )
                    }

                    StatCard(
                        title: "completion",
                        value: String(format: "%.1f%%", completionPercentage),
                        subtitle: "of days documented",
                        icon: "chart.pie"
                    )
                }
                .padding(.horizontal, 24)

                // Visual progress
                VStack(alignment: .leading, spacing: 12) {
                    Text("growth progress")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(Color(hex: "000080").opacity(0.7))

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: "E5E5EA"))

                            // Progress
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: "000080"))
                                .frame(width: geometry.size.width * CGFloat(completionPercentage / 100))
                        }
                    }
                    .frame(height: 12)
                }
                .padding(.horizontal, 24)

                Spacer()

                // Footer message
                VStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: "000080").opacity(0.5))

                    Text("every day is a seed")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(Color(hex: "000080").opacity(0.5))
                }
                .padding(.bottom, 40)
            }
        }
    }

    private var completionPercentage: Double {
        guard viewModel.todayDayOfYear > 0 else { return 0 }
        return (Double(viewModel.memoriesCount) / Double(viewModel.todayDayOfYear)) * 100
    }
}

/// A single stat card
struct StatCard: View {
    let title: String
    let value: String
    var subtitle: String? = nil
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "000080").opacity(0.7))

                Text(title)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(Color(hex: "000080").opacity(0.7))
            }

            Text(value)
                .font(.system(.title, design: .monospaced))
                .fontWeight(.semibold)
                .foregroundColor(Color(hex: "000080"))

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(Color(hex: "000080").opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Preview

#Preview {
    StatsView(viewModel: GardenViewModel())
}
