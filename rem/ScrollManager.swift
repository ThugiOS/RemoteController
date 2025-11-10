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
//class ScrollManager: ObservableObject {
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
//        // Запускаем скролл через 5 секунд
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
//    
////    private func startDirectionTimer() {
////        // Меняем направление каждые 15 секунд
////        directionTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { _ in
////            guard self.isScrollingActive else { return }
////            
////            self.currentDirection = self.currentDirection == .down ? .up : .down
////        }
////    }
//}
//
//struct ContentView: View {
//    @StateObject private var scrollManager = ScrollManager()
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            // Переключатель в основном окне
//            if #available(macOS 14.0, *) {
//                Toggle("Системный автоскролл", isOn: $scrollManager.isScrollingEnabled)
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
//            
//            // Информация о статусе
//            VStack(spacing: 10) {
//                if scrollManager.isScrollingEnabled {
//                    Text("Системный скролл активен")
//                        .foregroundColor(.green)
//                        .font(.headline)
//                    
//                    Text("Скролл начнется через 5 секунд после включения")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                    
//                    Text("Направление меняется каждые 5 секунд")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                } else {
//                    Text("Скролл отключен")
//                        .foregroundColor(.red)
//                        .font(.headline)
//                }
//            }
//            
//            Spacer()
//            
//            // Инструкция
//            VStack(spacing: 8) {
//                Text("Как использовать:")
//                    .font(.headline)
//                
//                Text("1. Включите переключатель")
//                Text("2. Перейдите в любое приложение")
//                Text("3. Через 5 секунд начнется автоскролл")
//                Text("4. Направление меняется каждые 5 секунд")
//            }
//            .font(.caption)
//            .foregroundColor(.secondary)
//            .multilineTextAlignment(.center)
//            
//            Spacer()
//        }
//        .padding()
//        .frame(width: 400, height: 300)
//    }
//}
//
//// Менюбар приложение
//class AppDelegate: NSObject, NSApplicationDelegate {
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
//
//@main
//struct AutoScrollApp: App {
//    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
//    
//    var body: some Scene {
//        Settings {
//            EmptyView()
//        }
//    }
//}


import SwiftUI
import AppKit
import ApplicationServices
import Combine

class ScrollManager: ObservableObject {
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
        
        // Запускаем скролл через 5 секунд
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

// Красивая кнопка-переключатель
struct BeautifulToggle: View {
    @Binding var isOn: Bool
    var title: String
    var subtitle: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(isOn ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: 50, height: 30)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .offset(x: isOn ? 10 : -10)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
            }
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isOn.toggle()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.controlBackgroundColor))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

// Карточка с информацией
struct InfoCard: View {
    var icon: String
    var title: String
    var description: String
    var color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.controlBackgroundColor))
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
        )
    }
}

// Анимированный индикатор статуса
struct StatusIndicator: View {
    var isActive: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(isActive ? Color.green : Color.red)
                .frame(width: 8, height: 8)
                .scaleEffect(isActive ? 1.2 : 1.0)
                .animation(
                    .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                    value: isActive
                )
            
            Text(isActive ? "Активно" : "Неактивно")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isActive ? .green : .red)
        }
    }
}

struct ContentView: View {
    @StateObject private var scrollManager = ScrollManager()
    @State private var isHovered = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Заголовок
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "scroll")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text("AutoScroll Pro")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Text("Автоматическая прокрутка содержимого")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 10)
            
            // Основной переключатель
            if #available(macOS 14.0, *) {
                BeautifulToggle(
                    isOn: $scrollManager.isScrollingEnabled,
                    title: "Системный автоскролл",
                    subtitle: "Включить автоматическую прокрутку"
                )
                .onChange(of: scrollManager.isScrollingEnabled) { oldValue, newValue in
                    if newValue {
                        scrollManager.startScrolling()
                    } else {
                        scrollManager.stopScrolling()
                    }
                }
            } else {
                // Fallback on earlier versions
            }
            
            // Статус
            VStack(spacing: 15) {
                StatusIndicator(isActive: scrollManager.isScrollingEnabled)
                
                if scrollManager.isScrollingEnabled {
                    Text("Скролл начнется через 5 секунд")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: scrollManager.isScrollingEnabled)
            
            // Информационные карточки
            VStack(spacing: 12) {
                InfoCard(
                    icon: "clock",
                    title: "Автозапуск",
                    description: "Скролл начинается через 5 секунд после включения",
                    color: .orange
                )
                
                InfoCard(
                    icon: "arrow.up.arrow.down",
                    title: "Смена направления",
                    description: "Направление меняется случайно каждые 3-15 секунд",
                    color: .purple
                )
                
                InfoCard(
                    icon: "app.badge",
                    title: "Системное приложение",
                    description: "Работает в любом приложении на вашем Mac",
                    color: .blue
                )
            }
            
            Spacer()
            
            // Футер с инструкцией
            VStack(spacing: 8) {
                Text("Как использовать")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 4) {
                    InstructionStep(number: "1", text: "Включите переключатель выше")
                    InstructionStep(number: "2", text: "Перейдите в нужное приложение")
                    InstructionStep(number: "3", text: "Подождите 5 секунд")
                    InstructionStep(number: "4", text: "Наслаждайтесь автоскроллом!")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.1))
            )
        }
        .padding(20)
        .frame(width: 420, height: 580)
        .background(
            LinearGradient(
                colors: [
                    Color(.windowBackgroundColor),
                    Color(.controlBackgroundColor)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

struct InstructionStep: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(number)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 16, height: 16)
                .background(Circle().fill(Color.blue))
            
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}

// Менюбар приложение
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem!
    var scrollManager = ScrollManager()
    var popover = NSPopover()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Создаем иконку в менюбаре
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusBarItem.button {
            // Используем красивую SF Symbol
            let config = NSImage.SymbolConfiguration(pointSize: 14, weight: .medium)
            button.image = NSImage(systemSymbolName: "scroll", accessibilityDescription: "Auto Scroll")?
                .withSymbolConfiguration(config)
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
        
        popover.contentSize = NSSize(width: 420, height: 580)
        popover.contentViewController = NSHostingController(rootView: contentView)
        popover.behavior = .transient
        popover.animates = true
    }
    
    @objc
    func togglePopover() {
        if let button = statusBarItem.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                // Активируем приложение при показе popover
                NSApplication.shared.activate(ignoringOtherApps: true)
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

@main
struct AutoScrollApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
        .windowStyle(.hiddenTitleBar)
    }
}
