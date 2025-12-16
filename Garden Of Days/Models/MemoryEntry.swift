//
//  MemoryEntry.swift
//  Garden Of Days
//
//  Created by Mayank Sharma on 15/12/25.
//

import Foundation
import SwiftData

@Model
final class MemoryEntry {
    @Attribute(.unique) var date: Date
    var content: String
    var doodleAssetName: String
    var createdAt: Date
    var updatedAt: Date

    // Computed property for display date
    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd.MM"
        return formatter.string(from: date).lowercased()
    }

    // Day of year (1-365/366)
    var dayOfYear: Int {
        Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
    }

    init(date: Date, content: String, doodleAssetName: String) {
        // Normalize date to start of day
        self.date = Calendar.current.startOfDay(for: date)
        self.content = content
        self.doodleAssetName = doodleAssetName
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// Extension for date utilities
extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var dayOfYear: Int {
        Calendar.current.ordinality(of: .day, in: .year, for: self) ?? 1
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    static func dateForDayOfYear(_ day: Int, year: Int) -> Date? {
        var components = DateComponents()
        components.year = year
        components.day = day
        return Calendar.current.date(from: components)
    }

    var year: Int {
        Calendar.current.component(.year, from: self)
    }

    static var daysInCurrentYear: Int {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())
        var components = DateComponents()
        components.year = year
        components.month = 12
        components.day = 31
        guard let lastDay = calendar.date(from: components) else { return 365 }
        return calendar.ordinality(of: .day, in: .year, for: lastDay) ?? 365
    }

    static var daysLeftInYear: Int {
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
