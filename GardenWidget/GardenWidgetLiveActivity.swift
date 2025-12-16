//
//  GardenWidgetLiveActivity.swift
//  GardenWidget
//
//  Created by Mayank Sharma on 16/12/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct GardenWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct GardenWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: GardenWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension GardenWidgetAttributes {
    fileprivate static var preview: GardenWidgetAttributes {
        GardenWidgetAttributes(name: "World")
    }
}

extension GardenWidgetAttributes.ContentState {
    fileprivate static var smiley: GardenWidgetAttributes.ContentState {
        GardenWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: GardenWidgetAttributes.ContentState {
         GardenWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: GardenWidgetAttributes.preview) {
   GardenWidgetLiveActivity()
} contentStates: {
    GardenWidgetAttributes.ContentState.smiley
    GardenWidgetAttributes.ContentState.starEyes
}
