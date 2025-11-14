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
        autoRepeatTimer = Timer.scheduledTimer(withTimeInterval: 90.0, repeats: true) { _ in
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
