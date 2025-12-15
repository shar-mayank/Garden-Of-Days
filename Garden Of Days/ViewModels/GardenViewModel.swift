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

    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd.MM"
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

    var viewMode: ViewMode = .void
    var gardenDays: [GardenDay] = []
    var selectedDay: GardenDay?
    var showEntrySheet: Bool = false
    var showToast: Bool = false
    var toastMessage: String = ""

    private var modelContext: ModelContext?
    private let doodleManager = DoodleManager.shared

    // MARK: - Computed Properties

    var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }

    var daysLeftInYear: Int {
        Date.daysLeftInYear
    }

    var totalDaysInYear: Int {
        Date.daysInCurrentYear
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
        viewMode == .void ? Color.white : Color(hex: "000080")
    }

    var secondaryColor: Color {
        viewMode == .void ? Color.white.opacity(0.6) : Color(hex: "000080").opacity(0.6)
    }

    // MARK: - Initialization

    func configure(with modelContext: ModelContext) {
        self.modelContext = modelContext
        loadGardenDays()
    }

    // MARK: - Data Loading

    func loadGardenDays() {
        let calendar = Calendar.current
        let year = currentYear
        var days: [GardenDay] = []

        // Generate all days of the year
        for dayOfYear in 1...totalDaysInYear {
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

        // Load existing memories
        loadMemories()
    }

    private func loadMemories() {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<MemoryEntry>()

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

        // Check if memory already exists for this day
        if let existingMemory = day.memory {
            // Update existing
            existingMemory.content = content
            existingMemory.updatedAt = Date()
        } else {
            // Create new memory with random doodle
            let doodleName = doodleManager.getRandomDoodle()
            let newMemory = MemoryEntry(
                date: day.date,
                content: content,
                doodleAssetName: doodleName
            )
            context.insert(newMemory)

            // Update garden day
            if let index = gardenDays.firstIndex(where: { $0.id == day.id }) {
                gardenDays[index].memory = newMemory
            }
        }

        do {
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
