//
//  GardenViewModel.swift
//  Garden Of Days
//
//  Created by Mayank Sharma on 15/12/25.
//

import Foundation
import SwiftUI
import SwiftData

/// View mode for the garden display
enum ViewMode: String, CaseIterable {
    case void = "void"      // Dark mode with dots
    case growth = "growth"  // Light mode with flowers
}

/// Represents a single day in the garden
struct GardenDay: Identifiable {
    let id: Int  // Day of year (1-365/366)
    let date: Date
    var memory: MemoryEntry?

    var hasMemory: Bool {
        memory != nil
    }

    var isPast: Bool {
        Calendar.current.startOfDay(for: date) < Calendar.current.startOfDay(for: Date())
    }

    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd.MM.yyyy"
        return formatter.string(from: date).lowercased()
    }

    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM"
        return formatter.string(from: date)
    }
}

@Observable
final class GardenViewModel {
    // MARK: - Properties

    var viewMode: ViewMode {
        didSet {
            // Persist view mode to UserDefaults
            UserDefaults.standard.set(viewMode.rawValue, forKey: "savedViewMode")
        }
    }
    var isDragRevealMode: Bool = false  // When true, dragging reveals flowers instead of opening journal
    var gardenDays: [GardenDay] = []
    var selectedDay: GardenDay?
    var showEntrySheet: Bool = false
    var showToast: Bool = false
    var toastMessage: String = ""
    var showYearPicker: Bool = false

    // Selected year (defaults to current year)
    var selectedYear: Int = Calendar.current.component(.year, from: Date())

    // Year range: 2004-2069
    static let minYear = 2004
    static let maxYear = 2069
    static var yearRange: [Int] { Array(minYear...maxYear) }

    private var modelContext: ModelContext?
    private let doodleManager = DoodleManager.shared

    // MARK: - Computed Properties

    var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }

    var isCurrentYear: Bool {
        selectedYear == currentYear
    }

    /// Check if a year is a leap year
    static func isLeapYear(_ year: Int) -> Bool {
        (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
    }

    /// Get number of days in a specific year (handles leap years)
    static func daysInYear(_ year: Int) -> Int {
        isLeapYear(year) ? 366 : 365
    }

    /// Cumulative days left until end of selected year
    /// - Current year: days remaining in current year
    /// - Past year: 0
    /// - Future year: days left in current year + all days in years between + days in selected year
    var daysLeftInYear: Int {
        if selectedYear < currentYear {
            return 0 // Past year - no days left
        } else if selectedYear == currentYear {
            return Date.daysLeftInYear
        } else {
            // Future year - cumulative calculation
            var total = Date.daysLeftInYear // Remaining days in current year

            // Add full years between current year and selected year
            for year in (currentYear + 1)..<selectedYear {
                total += GardenViewModel.daysInYear(year)
            }

            // Add all days of the selected year
            total += GardenViewModel.daysInYear(selectedYear)

            return total
        }
    }

    var daysInSelectedYear: Int {
        GardenViewModel.daysInYear(selectedYear)
    }

    var totalDaysInYear: Int {
        daysInSelectedYear
    }

    var memoriesCount: Int {
        gardenDays.filter { $0.hasMemory }.count
    }

    var todayDayOfYear: Int {
        Date().dayOfYear
    }

    // Trial days (placeholder)
    var trialDaysLeft: Int {
        14
    }

    // MARK: - Colors

    var backgroundColor: Color {
        viewMode == .void ? Color.black : Color(hex: "E5E5EA")
    }

    var primaryColor: Color {
        viewMode == .void ? Color.white : Color(hex: "f670b2")
    }

    var secondaryColor: Color {
        viewMode == .void ? Color.white.opacity(0.6) : Color(hex: "f670b2").opacity(0.6)
    }

    // MARK: - Initialization

    init() {
        // Load saved view mode or default to growth (light mode) for first-time users
        if let savedMode = UserDefaults.standard.string(forKey: "savedViewMode"),
           let mode = ViewMode(rawValue: savedMode) {
            self.viewMode = mode
        } else {
            // First time opening app - default to light mode (growth)
            self.viewMode = .growth
        }
    }

    func configure(with modelContext: ModelContext) {
        self.modelContext = modelContext
        loadGardenDays()
    }

    // MARK: - Data Loading

    func loadGardenDays() {
        loadGardenDays(for: selectedYear)
    }

    func loadGardenDays(for year: Int) {
        var days: [GardenDay] = []

        // Generate all days of the year
        let daysInYear = daysInSelectedYear
        for dayOfYear in 1...daysInYear {
            if let date = Date.dateForDayOfYear(dayOfYear, year: year) {
                let gardenDay = GardenDay(
                    id: dayOfYear,
                    date: date,
                    memory: nil
                )
                days.append(gardenDay)
            }
        }

        self.gardenDays = days

        // Load existing memories for this year
        loadMemories(for: year)
    }

    private func loadMemories(for year: Int) {
        guard let context = modelContext else { return }

        // Get date range for the selected year
        let calendar = Calendar.current
        var startComponents = DateComponents()
        startComponents.year = year
        startComponents.month = 1
        startComponents.day = 1

        var endComponents = DateComponents()
        endComponents.year = year
        endComponents.month = 12
        endComponents.day = 31

        guard let startDate = calendar.date(from: startComponents),
              let endDate = calendar.date(from: endComponents) else { return }

        // Fetch memories for this year only
        let descriptor = FetchDescriptor<MemoryEntry>(
            predicate: #Predicate<MemoryEntry> { memory in
                memory.date >= startDate && memory.date <= endDate
            }
        )

        do {
            let memories = try context.fetch(descriptor)

            // Map memories to garden days
            for memory in memories {
                let dayOfYear = memory.dayOfYear
                if let index = gardenDays.firstIndex(where: { $0.id == dayOfYear }) {
                    gardenDays[index].memory = memory
                }
            }
        } catch {
            print("Error loading memories: \(error)")
        }
    }

    private func loadMemories() {
        loadMemories(for: selectedYear)
    }

    /// Reload memories from persistent storage (call on orientation change, app resume, etc.)
    func reloadMemories() {
        guard modelContext != nil else { return }

        // Clear existing memory references first
        for index in gardenDays.indices {
            gardenDays[index].memory = nil
        }

        // Reload from database for current selected year
        loadMemories(for: selectedYear)
    }

    /// Change to a different year
    func changeYear(to year: Int) {
        guard year >= GardenViewModel.minYear && year <= GardenViewModel.maxYear else { return }
        selectedYear = year
        loadGardenDays(for: year)
    }

    // MARK: - Actions

    func selectToday() {
        let todayIndex = todayDayOfYear - 1
        if todayIndex >= 0 && todayIndex < gardenDays.count {
            selectedDay = gardenDays[todayIndex]
            showEntrySheet = true
        }
    }

    func selectDay(_ day: GardenDay) {
        selectedDay = day
        showToast(message: day.displayDate)

        // Open entry sheet after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showEntrySheet = true
        }
    }

    func showToast(message: String) {
        toastMessage = message
        showToast = true

        // Auto-hide toast
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showToast = false
        }
    }

    // MARK: - Memory Management

    func saveMemory(content: String, for day: GardenDay) {
        guard let context = modelContext else { return }

        // First check if memory already exists in the database for this day
        let dayOfYear = day.id
        let year = currentYear

        // Find the exact date for this day of year
        guard let targetDate = Date.dateForDayOfYear(dayOfYear, year: year) else { return }
        let startOfDay = Calendar.current.startOfDay(for: targetDate)

        // Fetch existing memory from database
        let descriptor = FetchDescriptor<MemoryEntry>(
            predicate: #Predicate<MemoryEntry> { memory in
                memory.date == startOfDay
            }
        )

        do {
            let existingMemories = try context.fetch(descriptor)

            if let existingMemory = existingMemories.first {
                // Update existing memory - keep the same doodle!
                existingMemory.content = content
                existingMemory.updatedAt = Date()

                // Update garden day reference
                if let index = gardenDays.firstIndex(where: { $0.id == day.id }) {
                    gardenDays[index].memory = existingMemory
                }
            } else {
                // Create new memory with random doodle (only for truly new entries)
                let doodleName = doodleManager.getRandomDoodle()
                let newMemory = MemoryEntry(
                    date: startOfDay,
                    content: content,
                    doodleAssetName: doodleName
                )
                context.insert(newMemory)

                // Update garden day
                if let index = gardenDays.firstIndex(where: { $0.id == day.id }) {
                    gardenDays[index].memory = newMemory
                }
            }

            try context.save()
        } catch {
            print("Error saving memory: \(error)")
        }
    }

    func deleteMemory(for day: GardenDay) {
        guard let context = modelContext,
              let memory = day.memory else { return }

        context.delete(memory)

        // Update garden day
        if let index = gardenDays.firstIndex(where: { $0.id == day.id }) {
            gardenDays[index].memory = nil
        }

        do {
            try context.save()
        } catch {
            print("Error deleting memory: \(error)")
        }
    }

    // MARK: - View Mode

    func toggleViewMode() {
        withAnimation(.easeInOut(duration: 0.3)) {
            viewMode = viewMode == .void ? .growth : .void
        }
    }

    func setViewMode(_ mode: ViewMode) {
        withAnimation(.easeInOut(duration: 0.3)) {
            viewMode = mode
        }
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
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
