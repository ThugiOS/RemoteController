//
//  AutoScrollApp.swift
//  rem
//
//  Created by Никитин Артем on 9.11.25.
//

import SwiftUI


@main
struct AutoScrollApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
