//
//  NotificationManager.swift
//  Garden Of Days
//
//  Created by Mayank Sharma on 26/12/25.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    // MARK: - Request Permission
    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    // MARK: - Check Permission Status
    func checkNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }

    // MARK: - Schedule Daily Reminder
    func scheduleDailyReminder() {
        // Remove any existing notifications first
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyJournalReminder"])

        // Create the notification content
        let content = UNMutableNotificationContent()
        content.title = "Plant a flower today"
        content.body = "It's time to journal about your day and write your heart out."
        content.sound = .default

        // Create date components for 10:00 PM
        var dateComponents = DateComponents()
        dateComponents.hour = 22  // 10:00 PM in 24-hour format
        dateComponents.minute = 0

        // Create the trigger for daily notification at 10:00 PM
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        // Create the request
        let request = UNNotificationRequest(
            identifier: "dailyJournalReminder",
            content: content,
            trigger: trigger
        )

        // Schedule the notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Daily reminder scheduled for 10:00 PM")
            }
        }
    }

    // MARK: - Cancel Daily Reminder
    func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyJournalReminder"])
    }

    // MARK: - Setup Notifications
    func setupNotifications() {
        requestNotificationPermission { granted in
            if granted {
                self.scheduleDailyReminder()
            }
        }
    }
}
