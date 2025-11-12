//
//  ScrollManager.swift
//  rem
//
//  Created by Никитин Артем on 8.11.25.
//


//import SwiftUI
//import AppKit
//import ApplicationServices
//import Combine
//
//final class ScrollManager: ObservableObject {
//    @Published var isScrollingEnabled = false
//    private var scrollTimer: Timer?
//    private var directionTimer: Timer?
//    private var currentDirection: ScrollDirection = .down
//    private var isScrollingActive = false
//    
//    enum ScrollDirection {
//        case up, down
//    }
//    
//    func startScrolling() {
//        stopScrolling()
//        isScrollingActive = false
//        
//        // need 10 minutes
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//            guard self.isScrollingEnabled else { return }
//            
//            self.isScrollingActive = true
//            self.startScrollTimer()
//            self.startDirectionTimer()
//        }
//    }
//    
//    func stopScrolling() {
//        scrollTimer?.invalidate()
//        directionTimer?.invalidate()
//        scrollTimer = nil
//        directionTimer = nil
//        isScrollingActive = false
//    }
//    
//    private func startScrollTimer() {
//        scrollTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
//            guard self.isScrollingActive else { return }
//            
//            let scrollValue = self.currentDirection == .down ? 2 : -2
//            
//            // Создаем событие скролла
//            let event = CGEvent(scrollWheelEvent2Source: nil,
//                              units: .pixel,
//                              wheelCount: 1,
//                              wheel1: Int32(scrollValue),
//                              wheel2: 0,
//                              wheel3: 0)
//            
//            // Отправляем событие в систему
//            event?.post(tap: .cghidEventTap)
//        }
//    }
//    
//    private func startDirectionTimer() {
//        directionTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval.random(in: 3...15), repeats: true) { _ in
//            guard self.isScrollingActive else { return }
//            
//            self.currentDirection = self.currentDirection == .down ? .up : .down
//            
//            // Перезапускаем таймер с новым случайным интервалом
//            self.directionTimer?.invalidate()
//            self.startDirectionTimer()
//        }
//    }
//}
//
//
//
//
//
//struct ContentView: View {
//    @StateObject private var scrollManager = ScrollManager()
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            // Переключатель в основном окне
//            if #available(macOS 14.0, *) {
//                Toggle("Scroll", isOn: $scrollManager.isScrollingEnabled)
//                    .toggleStyle(.switch)
//                    .onChange(of: scrollManager.isScrollingEnabled) { oldValue, newValue in
//                        if newValue {
//                            scrollManager.startScrolling()
//                        } else {
//                            scrollManager.stopScrolling()
//                        }
//                    }
//                    .padding()
//            } else {
//                // Fallback on earlier versions
//            }
//        }
//        .padding()
//        .frame(width: 350, height: 100)
//    }
//}
//
//
//
//
//
//// Менюбар приложение
//final class AppDelegate: NSObject, NSApplicationDelegate {
//    var statusBarItem: NSStatusItem!
//    var scrollManager = ScrollManager()
//    var popover = NSPopover()
//    
//    func applicationDidFinishLaunching(_ notification: Notification) {
//        // Создаем иконку в менюбаре
//        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
//        
//        if let button = statusBarItem.button {
//            button.image = NSImage(systemSymbolName: "scroll", accessibilityDescription: "Auto Scroll")
//            button.action = #selector(togglePopover)
//        }
//        
//        // Настраиваем popover
//        setupPopover()
//        
//        // Запрашиваем разрешения для доступности
//        requestAccessibilityPermissions()
//    }
//    
//    private func setupPopover() {
//        let contentView = ContentView()
//            .environmentObject(scrollManager)
//        
//        popover.contentSize = NSSize(width: 400, height: 300)
//        popover.contentViewController = NSHostingController(rootView: contentView)
//        popover.behavior = .transient
//    }
//    
//    @objc
//    func togglePopover() {
//        if let button = statusBarItem.button {
//            if popover.isShown {
//                popover.performClose(nil)
//            } else {
//                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
//            }
//        }
//    }
//    
//    private func requestAccessibilityPermissions() {
//        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true]
//        let accessibilityEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)
//        
//        if !accessibilityEnabled {
//            print("Требуется разрешение на доступность в Системных настройках")
//        }
//    }
//}

import SwiftUI
import AppKit
import ApplicationServices
import Combine

final class ScrollManager: ObservableObject {
    @Published var isScrollingEnabled = false
    private var scrollTimer: Timer?
    private var directionTimer: Timer?
    private var scrollDurationTimer: Timer?
    private var autoRepeatTimer: Timer?
    private var currentDirection: ScrollDirection = .down
    private var isScrollingActive = false
    
    enum ScrollDirection {
        case up, down
    }
    
    func startAutoRepeatScrolling() {
        stopAllTimers()
        isScrollingEnabled = true
        
        // Немедленно запускаем первый цикл скролла
        startScrollCycle()
        
        // Запускаем таймер автоматического повторения каждые 15 минут
        autoRepeatTimer = Timer.scheduledTimer(withTimeInterval: 100.0, repeats: true) { _ in
            self.startScrollCycle()
        }
    }
    
    func stopAutoRepeatScrolling() {
        stopAllTimers()
        isScrollingEnabled = false
    }
    
    private func startScrollCycle() {
        stopScrolling()
        isScrollingActive = false
        
        print("🔄 Подготовка к скроллу...")
        
        // Запускаем скролл через 5 секунд
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            guard self.isScrollingEnabled else { return }
            
            print("🎯 Начинаем скролл (10 секунд)")
            self.isScrollingActive = true
            self.startScrollTimer()
            self.startDirectionTimer()
            
            // Автоматически отключаем скролл через 10 секунд
            self.scrollDurationTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { _ in
                print("⏹️ Завершаем скролл")
                self.stopScrolling()
                
                // Следующий цикл начнется автоматически через 15 минут благодаря autoRepeatTimer
            }
        }
    }
    
    private func stopScrolling() {
        scrollTimer?.invalidate()
        directionTimer?.invalidate()
        scrollDurationTimer?.invalidate()
        
        scrollTimer = nil
        directionTimer = nil
        scrollDurationTimer = nil
        isScrollingActive = false
    }
    
    private func stopAllTimers() {
        stopScrolling()
        autoRepeatTimer?.invalidate()
        autoRepeatTimer = nil
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
    @State private var nextScrollTime: Date?
    @State private var countdownTimer: Timer?
    
    var body: some View {
        VStack(spacing: 20) {
            // Переключатель автоматического повторения
            if #available(macOS 14.0, *) {
                Toggle("Автоскролл", isOn: Binding(
                    get: { scrollManager.isScrollingEnabled },
                    set: { newValue in
                        if newValue {
                            scrollManager.startAutoRepeatScrolling()
                            startCountdownTimer()
                        } else {
                            scrollManager.stopAutoRepeatScrolling()
                            stopCountdownTimer()
                        }
                    }
                ))
                .toggleStyle(.switch)
                .padding()
            } else {
                Toggle("Автоскролл", isOn: Binding(
                    get: { scrollManager.isScrollingEnabled },
                    set: { newValue in
                        if newValue {
                            scrollManager.startAutoRepeatScrolling()
                            startCountdownTimer()
                        } else {
                            scrollManager.stopAutoRepeatScrolling()
                            stopCountdownTimer()
                        }
                    }
                ))
                .padding()
            }
            
            // Отображение времени до следующего скролла
            if let nextTime = nextScrollTime, scrollManager.isScrollingEnabled {
                VStack {
                    Text("Следующий скролл через:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(countdownString(from: nextTime))
                        .font(.title2.monospacedDigit())
                        .foregroundColor(.primary)
                }
            }
        }
        .padding()
        .frame(width: 350, height: 150)
        .onDisappear {
            stopCountdownTimer()
        }
    }
    
    private func startCountdownTimer() {
        stopCountdownTimer()
        updateNextScrollTime()
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateNextScrollTime()
        }
    }
    
    private func stopCountdownTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        nextScrollTime = nil
    }
    
    private func updateNextScrollTime() {
        // Следующий скролл будет через 15 минут от текущего времени
        nextScrollTime = Date().addingTimeInterval(900)
    }
    
    private func countdownString(from date: Date) -> String {
        let remaining = date.timeIntervalSinceNow
        
        if remaining <= 0 {
            return "00:00"
        }
        
        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// Менюбар приложение (остается без изменений)
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
