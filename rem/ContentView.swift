import SwiftUI


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
//            if let nextTime = nextScrollTime, scrollManager.isScrollingEnabled {
//                VStack {
//                    Text("Следующий скролл через:")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                    Text(countdownString(from: nextTime))
//                        .font(.title2.monospacedDigit())
//                        .foregroundColor(.primary)
//                }
//            }
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
