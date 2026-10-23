//
//  ChallengeFinalWidgetLiveActivity.swift
//  ChallengeFinalWidget
//
//  Created by Débora Cristina Silva Ferreira on 23/10/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct ChallengeFinalWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct ChallengeFinalWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ChallengeFinalWidgetAttributes.self) { context in
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

extension ChallengeFinalWidgetAttributes {
    fileprivate static var preview: ChallengeFinalWidgetAttributes {
        ChallengeFinalWidgetAttributes(name: "World")
    }
}

extension ChallengeFinalWidgetAttributes.ContentState {
    fileprivate static var smiley: ChallengeFinalWidgetAttributes.ContentState {
        ChallengeFinalWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: ChallengeFinalWidgetAttributes.ContentState {
         ChallengeFinalWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: ChallengeFinalWidgetAttributes.preview) {
   ChallengeFinalWidgetLiveActivity()
} contentStates: {
    ChallengeFinalWidgetAttributes.ContentState.smiley
    ChallengeFinalWidgetAttributes.ContentState.starEyes
}
