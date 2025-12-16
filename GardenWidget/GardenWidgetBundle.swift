//
//  GardenWidgetBundle.swift
//  GardenWidget
//
//  Created by Mayank Sharma on 16/12/25.
//

import WidgetKit
import SwiftUI

@main
struct GardenWidgetBundle: WidgetBundle {
    var body: some Widget {
        GardenWidget()
        GardenWidgetControl()
        GardenWidgetLiveActivity()
    }
}
