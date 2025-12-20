//
//  Garden_Of_DaysApp.swift
//  Garden Of Days
//
//  Created by Mayank Sharma on 15/12/25.
//

import SwiftUI
import SwiftData
import WidgetKit

@main
struct Garden_Of_DaysApp: App {
    @State private var widgetDeepLink: URL?
    @Environment(\.scenePhase) private var scenePhase

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            MemoryEntry.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            SplashView(widgetDeepLink: $widgetDeepLink)
                .onOpenURL { url in
                    widgetDeepLink = url
                }
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                // Refresh widgets when app becomes active
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
}
