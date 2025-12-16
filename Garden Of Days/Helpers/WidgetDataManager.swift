//
//  WidgetDataManager.swift
//  Garden Of Days
//
//  Created by Mayank Sharma on 16/12/25.
//

import Foundation
import WidgetKit

/// Manages shared data between the main app and widgets via App Groups
class WidgetDataManager {
    static let shared = WidgetDataManager()

    // IMPORTANT: Replace with your actual App Group identifier after setting it up in Xcode
    static let appGroupIdentifier = "group.com.gardenofdays.shared"

    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: WidgetDataManager.appGroupIdentifier)
    }

    private init() {}

    // MARK: - Keys
    private enum Keys {
        static let memoriesCount = "widget_memoriesCount"
        static let daysLeftInYear = "widget_daysLeftInYear"
        static let currentYear = "widget_currentYear"
        static let memoriesWithDays = "widget_memoriesWithDays" // Array of day numbers that have memories
        static let totalDaysInYear = "widget_totalDaysInYear"
    }

    // MARK: - Save Data

    func updateWidgetData(memoriesCount: Int, memoriesDays: [Int], daysLeftInYear: Int, currentYear: Int, totalDaysInYear: Int) {
        sharedDefaults?.set(memoriesCount, forKey: Keys.memoriesCount)
        sharedDefaults?.set(memoriesDays, forKey: Keys.memoriesWithDays)
        sharedDefaults?.set(daysLeftInYear, forKey: Keys.daysLeftInYear)
        sharedDefaults?.set(currentYear, forKey: Keys.currentYear)
        sharedDefaults?.set(totalDaysInYear, forKey: Keys.totalDaysInYear)

        // Trigger widget refresh
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - Read Data

    func getMemoriesCount() -> Int {
        sharedDefaults?.integer(forKey: Keys.memoriesCount) ?? 0
    }

    func getDaysLeftInYear() -> Int {
        sharedDefaults?.integer(forKey: Keys.daysLeftInYear) ?? Date.daysLeftInYear
    }

    func getCurrentYear() -> Int {
        sharedDefaults?.integer(forKey: Keys.currentYear) ?? Calendar.current.component(.year, from: Date())
    }

    func getMemoriesDays() -> [Int] {
        sharedDefaults?.array(forKey: Keys.memoriesWithDays) as? [Int] ?? []
    }

    func getTotalDaysInYear() -> Int {
        sharedDefaults?.integer(forKey: Keys.totalDaysInYear) ?? 365
    }
}
