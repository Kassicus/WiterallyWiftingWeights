//
//  RestTimerManager.swift
//  WiterallyWiftingWeights
//
//  Drives the rest countdown between sets. Duration is clamped to 90–180s.
//  A local notification is scheduled so the alert still fires when the app
//  is backgrounded; it is cancelled if the timer is skipped or finishes early.
//

import Foundation
import Observation
import UserNotifications

@MainActor
@Observable
final class RestTimerManager {
    static let minDuration: TimeInterval = 90
    static let maxDuration: TimeInterval = 180
    private static let notificationID = "rest-timer-complete"

    private(set) var isRunning = false
    private(set) var endDate = Date()
    private(set) var duration: TimeInterval = 0

    /// Updated on every tick so SwiftUI views observing `remaining` refresh.
    private var now = Date()
    private var timer: Timer?

    var remaining: TimeInterval { max(0, endDate.timeIntervalSince(now)) }

    var progress: Double {
        guard duration > 0 else { return 0 }
        return min(1, max(0, 1 - remaining / duration))
    }

    func start(_ seconds: TimeInterval) {
        let clamped = clamp(seconds)
        now = Date()
        duration = clamped
        endDate = now.addingTimeInterval(clamped)
        isRunning = true
        startTimer()
        scheduleNotification(after: clamped)
        Haptics.light()
    }

    /// Adjust the running timer up or down (e.g. the -15 / +15 buttons).
    func adjust(by delta: TimeInterval) {
        guard isRunning else { return }
        now = Date()
        let newRemaining = min(max(remaining + delta, 1), Self.maxDuration)
        endDate = now.addingTimeInterval(newRemaining)
        duration = max(duration, newRemaining)
        scheduleNotification(after: newRemaining)
        Haptics.light()
    }

    func skip() {
        Haptics.light()
        stop()
    }

    /// Re-sync after returning from the background; fires completion if elapsed.
    func refresh() {
        guard isRunning else { return }
        now = Date()
        if remaining <= 0 { complete() }
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.tick() }
        }
    }

    private func tick() {
        now = Date()
        if remaining <= 0 { complete() }
    }

    private func complete() {
        Haptics.success()
        if soundEnabled { Sound.timerComplete() }
        stop()
    }

    /// Reads the Settings toggle directly from `UserDefaults` since this is a
    /// model object rather than a SwiftUI view. Falls back to the shared
    /// default when the key has never been written.
    private var soundEnabled: Bool {
        UserDefaults.standard.object(forKey: AppStorageKey.timerSound) as? Bool
            ?? AppStorageKey.timerSoundDefault
    }

    private func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        cancelNotification()
    }

    private func clamp(_ seconds: TimeInterval) -> TimeInterval {
        min(max(seconds, Self.minDuration), Self.maxDuration)
    }

    private func scheduleNotification(after seconds: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "Rest complete 💪"
        content.body = "Time for your next set."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, seconds), repeats: false)
        let request = UNNotificationRequest(identifier: Self.notificationID, content: content, trigger: trigger)

        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [Self.notificationID])
        center.add(request)
    }

    private func cancelNotification() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [Self.notificationID])
    }
}
