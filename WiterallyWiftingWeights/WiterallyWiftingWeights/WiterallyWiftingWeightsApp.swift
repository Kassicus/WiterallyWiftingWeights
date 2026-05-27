//
//  WiterallyWiftingWeightsApp.swift
//  WiterallyWiftingWeights
//
//  Created by Kason Suchow on 5/27/26.
//

import SwiftUI
import SwiftData

@main
struct WiterallyWiftingWeightsApp: App {
    @State private var restTimer = RestTimerManager()

    let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Exercise.self,
            WorkoutSession.self,
            LoggedExercise.self,
            SetEntry.self,
            WorkoutTemplate.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // The on-disk store is incompatible with the current schema — most
            // likely a model change during development that lightweight
            // migration can't perform (e.g. a renamed attribute). Reset the
            // store and try once more rather than crashing on launch.
            // NOTE: this discards local data; add a SchemaMigrationPlan before
            // shipping to preserve it.
            resetStore(at: modelConfiguration.url)
            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }
    }()

    /// Remove the SQLite store and its write-ahead/shared-memory sidecar files
    /// (named `default.store-wal` / `default.store-shm`).
    private static func resetStore(at url: URL) {
        let fileManager = FileManager.default
        let directory = url.deletingLastPathComponent()
        let name = url.lastPathComponent
        for fileName in [name, "\(name)-wal", "\(name)-shm"] {
            try? fileManager.removeItem(at: directory.appendingPathComponent(fileName))
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(restTimer)
        }
        .modelContainer(sharedModelContainer)
    }
}
