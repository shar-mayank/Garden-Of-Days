//
//  GardenWidget.swift
//  GardenWidget
//
//  Created by Mayank Sharma on 16/12/25.
//

import WidgetKit
import SwiftUI

// MARK: - Shared Data Manager (Widget Side)

class WidgetSharedData {
    static let shared = WidgetSharedData()

    // IMPORTANT: Must match the App Group identifier in the main app
    static let appGroupIdentifier = "group.com.gardenofdays.shared"

    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: WidgetSharedData.appGroupIdentifier)
    }

    private init() {}

    private enum Keys {
        static let memoriesCount = "widget_memoriesCount"
        static let daysLeftInYear = "widget_daysLeftInYear"
        static let currentYear = "widget_currentYear"
        static let memoriesWithDays = "widget_memoriesWithDays"
        static let totalDaysInYear = "widget_totalDaysInYear"
    }

    func getMemoriesCount() -> Int {
        guard let defaults = sharedDefaults,
              defaults.object(forKey: Keys.memoriesCount) != nil else {
            return 0
        }
        return defaults.integer(forKey: Keys.memoriesCount)
    }

    func getDaysLeftInYear() -> Int {
        guard let defaults = sharedDefaults,
              defaults.object(forKey: Keys.daysLeftInYear) != nil else {
            return calculateDaysLeftInYear()
        }
        let days = defaults.integer(forKey: Keys.daysLeftInYear)
        return days > 0 ? days : calculateDaysLeftInYear()
    }

    func getCurrentYear() -> Int {
        guard let defaults = sharedDefaults,
              defaults.object(forKey: Keys.currentYear) != nil else {
            return Calendar.current.component(.year, from: Date())
        }
        let year = defaults.integer(forKey: Keys.currentYear)
        return year > 0 ? year : Calendar.current.component(.year, from: Date())
    }

    func getMemoriesDays() -> Set<Int> {
        Set(sharedDefaults?.array(forKey: Keys.memoriesWithDays) as? [Int] ?? [])
    }

    func getTotalDaysInYear() -> Int {
        guard let defaults = sharedDefaults,
              defaults.object(forKey: Keys.totalDaysInYear) != nil else {
            return 365
        }
        let stored = defaults.integer(forKey: Keys.totalDaysInYear)
        return stored > 0 ? stored : 365
    }

    private func calculateDaysLeftInYear() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let year = calendar.component(.year, from: today)
        var components = DateComponents()
        components.year = year
        components.month = 12
        components.day = 31
        guard let lastDay = calendar.date(from: components) else { return 0 }
        // Add 1 to include today in the count
        let days = calendar.dateComponents([.day], from: today, to: lastDay).day ?? 0
        return max(0, days + 1)
    }
}

// MARK: - Timeline Entry

struct GardenEntry: TimelineEntry {
    let date: Date
    let daysLeft: Int
    let memoriesCount: Int
    let memoriesDays: Set<Int>
    let totalDaysInYear: Int
    let currentYear: Int
}

// MARK: - Timeline Provider

struct GardenProvider: TimelineProvider {
    func placeholder(in context: Context) -> GardenEntry {
        GardenEntry(
            date: Date(),
            daysLeft: 15,
            memoriesCount: 42,
            memoriesDays: Set(1...42),
            totalDaysInYear: 365,
            currentYear: 2025
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (GardenEntry) -> Void) {
        let entry = createEntry(for: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<GardenEntry>) -> Void) {
        let calendar = Calendar.current
        let now = Date()

        // Create entries for today and the next few days to ensure updates
        var entries: [GardenEntry] = []

        // Entry for right now
        entries.append(createEntry(for: now))

        // Create entries for the next 5 days at midnight
        // This ensures the widget updates even if the system doesn't wake it exactly at midnight
        for dayOffset in 1...5 {
            if let futureDate = calendar.date(byAdding: .day, value: dayOffset, to: now) {
                let startOfDay = calendar.startOfDay(for: futureDate)
                entries.append(createEntry(for: startOfDay))
            }
        }

        // Request refresh after the last entry's date, or use .atEnd for automatic refresh
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

    private func createEntry(for date: Date) -> GardenEntry {
        let data = WidgetSharedData.shared
        let calendar = Calendar.current

        // Always calculate days left dynamically based on the entry date
        let daysLeft = calculateDaysLeft(from: date)
        let year = calendar.component(.year, from: date)
        let totalDays = calendar.range(of: .day, in: .year, for: date)?.count ?? 365

        return GardenEntry(
            date: date,
            daysLeft: daysLeft,
            memoriesCount: data.getMemoriesCount(),
            memoriesDays: data.getMemoriesDays(),
            totalDaysInYear: totalDays,
            currentYear: year
        )
    }

    private func calculateDaysLeft(from date: Date) -> Int {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let year = calendar.component(.year, from: startOfDay)

        var endOfYearComponents = DateComponents()
        endOfYearComponents.year = year
        endOfYearComponents.month = 12
        endOfYearComponents.day = 31

        guard let lastDayOfYear = calendar.date(from: endOfYearComponents) else {
            return 0
        }

        // Calculate days remaining including today
        let days = calendar.dateComponents([.day], from: startOfDay, to: lastDayOfYear).day ?? 0
        return max(0, days + 1)
    }
}

// MARK: - Widget 1: Void Widget (Dark Grid - Large)

struct VoidWidgetView: View {
    var entry: GardenEntry
    @Environment(\.widgetFamily) var family

    private let columns = 19
    private let dotSize: CGFloat = 6
    private let spacing: CGFloat = 4

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 8) {
                // Days left header
                HStack {
                    Text("\(entry.daysLeft)")
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    Text("days left")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)

                // Grid of dots
                let availableHeight = geometry.size.height - 60
                let rows = min(Int(availableHeight / (dotSize + spacing)), (entry.totalDaysInYear + columns - 1) / columns)

                VStack(spacing: spacing) {
                    ForEach(0..<rows, id: \.self) { row in
                        HStack(spacing: spacing) {
                            ForEach(0..<columns, id: \.self) { col in
                                let dayIndex = row * columns + col + 1
                                if dayIndex <= entry.totalDaysInYear {
                                    dotView(for: dayIndex)
                                } else {
                                    Circle()
                                        .fill(Color.clear)
                                        .frame(width: dotSize, height: dotSize)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 8)

                Spacer(minLength: 0)
            }
        }
        .containerBackground(.black, for: .widget)
        .widgetURL(URL(string: "gardenofdays://void"))
    }

    @ViewBuilder
    private func dotView(for day: Int) -> some View {
        let today = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1

        if day == today {
            // Today - glowing dot
            Circle()
                .fill(Color.white)
                .frame(width: dotSize, height: dotSize)
                .shadow(color: .white.opacity(0.9), radius: 4)
                .shadow(color: .white.opacity(0.6), radius: 2)
        } else {
            Circle()
                .fill(dotColor(for: day))
                .frame(width: dotSize, height: dotSize)
        }
    }

    private func dotColor(for day: Int) -> Color {
        let today = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1

        if day < today {
            // Past days - white (days passed)
            return .white
        } else {
            // Future days - dim
            return .white.opacity(0.15)
        }
    }
}

struct VoidWidget: Widget {
    let kind: String = "VoidWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GardenProvider()) { entry in
            VoidWidgetView(entry: entry)
        }
        .configurationDisplayName("Garden Grid")
        .description("See your year at a glance with days left")
        .supportedFamilies([.systemLarge])
    }
}

// MARK: - Widget 2: Growth Widget (Light Flower - Small/Medium)

struct GrowthWidgetView: View {
    var entry: GardenEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            // Flower image (using SF Symbol as placeholder - you can use your custom asset)
            VStack(spacing: 4) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: family == .systemSmall ? 40 : 50))
                    .foregroundColor(Color(hex: "f670b2"))

                Text("time to write")
                    .font(.system(size: family == .systemSmall ? 11 : 13, weight: .medium, design: .monospaced))
                    .foregroundColor(Color(hex: "f670b2").opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(Color(hex: "E5E5EA"), for: .widget)
        .widgetURL(URL(string: "gardenofdays://growth"))
    }
}

struct GrowthWidget: Widget {
    let kind: String = "GrowthWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GardenProvider()) { entry in
            GrowthWidgetView(entry: entry)
        }
        .configurationDisplayName("Garden Flower")
        .description("A gentle reminder to write")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Widget 3: Memories Count Widget (Small)

struct MemoriesCountWidgetView: View {
    var entry: GardenEntry

    var body: some View {
        VStack(spacing: 4) {
            Text("\(entry.memoriesCount)")
                .font(.system(size: 44, weight: .bold, design: .monospaced))
                .foregroundColor(.white)

            Text(entry.memoriesCount == 1 ? "memory" : "memories")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.white.opacity(0.7))

            Text("in \(String(entry.currentYear))")
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(.black, for: .widget)
        .widgetURL(URL(string: "gardenofdays://void"))
    }
}

struct MemoriesCountWidget: Widget {
    let kind: String = "MemoriesCountWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GardenProvider()) { entry in
            MemoriesCountWidgetView(entry: entry)
        }
        .configurationDisplayName("Memories Count")
        .description("Total memories this year")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Color Extension for Widget

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Previews

#Preview("Void Widget", as: .systemLarge) {
    VoidWidget()
} timeline: {
    GardenEntry(date: .now, daysLeft: 15, memoriesCount: 42, memoriesDays: Set(1...42), totalDaysInYear: 365, currentYear: 2025)
}

#Preview("Growth Widget Small", as: .systemSmall) {
    GrowthWidget()
} timeline: {
    GardenEntry(date: .now, daysLeft: 15, memoriesCount: 42, memoriesDays: Set(1...42), totalDaysInYear: 365, currentYear: 2025)
}

#Preview("Memories Count", as: .systemSmall) {
    MemoriesCountWidget()
} timeline: {
    GardenEntry(date: .now, daysLeft: 15, memoriesCount: 42, memoriesDays: Set(1...42), totalDaysInYear: 365, currentYear: 2025)
}
