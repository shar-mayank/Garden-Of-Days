//
//  Garden_Of_DaysApp.swift
//  Garden Of Days
//
//  Created by Mayank Sharma on 15/12/25.
//

import SwiftUI
import SwiftData

@main
struct Garden_Of_DaysApp: App {
    @State private var widgetDeepLink: URL?

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
    }
}
