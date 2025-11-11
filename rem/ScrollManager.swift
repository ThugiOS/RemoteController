//
//  ScrollManager.swift
//  rem
//
//  Created by Никитин Артем on 8.11.25.
//


import SwiftUI
import AppKit
import ApplicationServices
import Combine

final class ScrollManager: ObservableObject {
    @Published var isScrollingEnabled = false
    private var scrollTimer: Timer?
    private var directionTimer: Timer?
    private var currentDirection: ScrollDirection = .down
    private var isScrollingActive = false
    
    enum ScrollDirection {
        case up, down
    }
    
    func startScrolling() {
        stopScrolling()
        isScrollingActive = false
        
        // need 10 minutes
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            guard self.isScrollingEnabled else { return }
            
            self.isScrollingActive = true
            self.startScrollTimer()
            self.startDirectionTimer()
        }
    }
    
    func stopScrolling() {
        scrollTimer?.invalidate()
        directionTimer?.invalidate()
        scrollTimer = nil
        directionTimer = nil
        isScrollingActive = false
    }
    
    private func startScrollTimer() {
        scrollTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            guard self.isScrollingActive else { return }
            
            let scrollValue = self.currentDirection == .down ? 2 : -2
            
            // Создаем событие скролла
            let event = CGEvent(scrollWheelEvent2Source: nil,
                              units: .pixel,
                              wheelCount: 1,
                              wheel1: Int32(scrollValue),
                              wheel2: 0,
                              wheel3: 0)
            
            // Отправляем событие в систему
            event?.post(tap: .cghidEventTap)
        }
    }
    
    private func startDirectionTimer() {
        directionTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval.random(in: 3...15), repeats: true) { _ in
            guard self.isScrollingActive else { return }
            
            self.currentDirection = self.currentDirection == .down ? .up : .down
            
            // Перезапускаем таймер с новым случайным интервалом
            self.directionTimer?.invalidate()
            self.startDirectionTimer()
        }
    }
}





struct ContentView: View {
    @StateObject private var scrollManager = ScrollManager()
    
    var body: some View {
        VStack(spacing: 20) {
            // Переключатель в основном окне
            if #available(macOS 14.0, *) {
                Toggle("Scroll", isOn: $scrollManager.isScrollingEnabled)
                    .toggleStyle(.switch)
                    .onChange(of: scrollManager.isScrollingEnabled) { oldValue, newValue in
                        if newValue {
                            scrollManager.startScrolling()
                        } else {
                            scrollManager.stopScrolling()
                        }
                    }
                    .padding()
            } else {
                // Fallback on earlier versions
            }
        }
        .padding()
        .frame(width: 350, height: 100)
    }
}





// Менюбар приложение
final class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem!
    var scrollManager = ScrollManager()
    var popover = NSPopover()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Создаем иконку в менюбаре
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusBarItem.button {
            button.image = NSImage(systemSymbolName: "scroll", accessibilityDescription: "Auto Scroll")
            button.action = #selector(togglePopover)
        }
        
        // Настраиваем popover
        setupPopover()
        
        // Запрашиваем разрешения для доступности
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
