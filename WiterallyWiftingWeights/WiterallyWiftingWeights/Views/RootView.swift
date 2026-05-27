//
//  RootView.swift
//  WiterallyWiftingWeights
//

import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var scenePhase
    @Environment(RestTimerManager.self) private var timer
    @AppStorage(AppStorageKey.appearance) private var appearanceRaw = AppearanceMode.dark.rawValue

    private var appearance: AppearanceMode { AppearanceMode(rawValue: appearanceRaw) ?? .dark }

    var body: some View {
        TabView {
            TodayView()
                .tabItem { Label("Today", systemImage: "dumbbell.fill") }
            CalendarView()
                .tabItem { Label("Calendar", systemImage: "calendar") }
            ExercisesView()
                .tabItem { Label("Exercises", systemImage: "list.bullet.rectangle") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .overlay(alignment: .bottom) {
            if timer.isRunning {
                RestTimerBar()
                    .padding(.horizontal)
                    .padding(.bottom, 58)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.3), value: timer.isRunning)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { timer.refresh() }
        }
        .task {
            SeedData.seedIfNeeded(context)
            await NotificationManager.requestAuthorization()
        }
        .preferredColorScheme(appearance.colorScheme)
    }
}

#Preview {
    RootView()
        .modelContainer(for: [Exercise.self, WorkoutSession.self, LoggedExercise.self, SetEntry.self],
                        inMemory: true)
        .environment(RestTimerManager())
}
