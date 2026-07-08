//
//  SettingsView.swift
//  WiterallyWiftingWeights
//

import SwiftUI

struct SettingsView: View {
    @AppStorage(AppStorageKey.defaultRest) private var defaultRest = 120.0
    @AppStorage(AppStorageKey.appearance) private var appearanceRaw = AppearanceMode.dark.rawValue
    @AppStorage(AppStorageKey.timerSound) private var timerSound = AppStorageKey.timerSoundDefault

    @State private var notificationStatus = "Checking…"

    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Picker("Theme", selection: $appearanceRaw) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Text(mode.label).tag(mode.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Tools") {
                    NavigationLink {
                        PlateCalculatorView()
                    } label: {
                        Label("Plate Calculator", systemImage: "circle.hexagongrid")
                    }
                }

                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Default rest: \(Int(defaultRest)) seconds")
                        Slider(value: $defaultRest,
                               in: RestTimerManager.minDuration...RestTimerManager.maxDuration,
                               step: 5)
                    }
                    Toggle("Sound when timer ends", isOn: $timerSound)
                        .onChange(of: timerSound) { _, isOn in
                            if isOn { Sound.timerComplete() }
                        }
                } header: {
                    Text("Rest Timer")
                } footer: {
                    Text("Rest between sets. Allowed range is \(Int(RestTimerManager.minDuration))–\(Int(RestTimerManager.maxDuration)) seconds. A buzz always plays; the sound is an extra cue and follows your ringer/silent switch.")
                }

                Section("Notifications") {
                    LabeledContent("Status", value: notificationStatus)
                    Button("Enable Notifications") {
                        Task {
                            await NotificationManager.requestAuthorization()
                            await refreshNotificationStatus()
                        }
                    }
                }

                Section {
                    LabeledContent("App", value: "WiterallyWiftingWeights")
                } footer: {
                    Text("Track your 5×5. Lift weights, literally.")
                }
            }
            .navigationTitle("Settings")
            .task { await refreshNotificationStatus() }
        }
    }

    private func refreshNotificationStatus() async {
        let status = await NotificationManager.authorizationStatus()
        switch status {
        case .authorized: notificationStatus = "Enabled"
        case .denied: notificationStatus = "Off — enable in iOS Settings"
        case .notDetermined: notificationStatus = "Not set"
        case .provisional: notificationStatus = "Provisional"
        case .ephemeral: notificationStatus = "Ephemeral"
        @unknown default: notificationStatus = "Unknown"
        }
    }
}
