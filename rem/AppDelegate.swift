//
//  AppDelegate.swift
//  rem
//
//  Created by Никитин Артем on 14.11.25.
//

import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem!
    var scrollManager = ScrollManager()
    var popover = NSPopover()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusBarItem.button {
            button.image = NSImage(systemSymbolName: "scroll", accessibilityDescription: "Auto Scroll")
            button.action = #selector(togglePopover)
        }
        
        setupPopover()
        requestAccessibilityPermissions()
    }
    
    private func setupPopover() {
        let contentView = ContentView()
            .environmentObject(scrollManager)
        
        popover.contentSize = NSSize(width: 400, height: 300)
        popover.contentViewController = NSHostingController(rootView: contentView)
        popover.behavior = .transient
    }
    
    @objc
    func togglePopover() {
        if let button = statusBarItem.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
    
    private func requestAccessibilityPermissions() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true]
        let accessibilityEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        if !accessibilityEnabled {
            print("Требуется разрешение на доступность в Системных настройках")
        }
    }
}
