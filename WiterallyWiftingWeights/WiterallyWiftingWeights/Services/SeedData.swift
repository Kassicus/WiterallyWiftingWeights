//
//  SeedData.swift
//  WiterallyWiftingWeights
//
//  Seeds the five core StrongLifts lifts on first launch (when the catalog
//  is empty). All weights are in pounds.
//

import Foundation
import SwiftData

enum SeedData {
    private static let defaultLiftNames = [
        "Squat",
        "Bench Press",
        "Barbell Row",
        "Overhead Press",
        "Deadlift"
    ]

    /// (name, ordered exercise names)
    private static let defaultTemplates: [(String, [String])] = [
        ("Workout A", ["Squat", "Bench Press", "Barbell Row"]),
        ("Workout B", ["Squat", "Overhead Press", "Deadlift"])
    ]

    @MainActor
    static func seedIfNeeded(_ context: ModelContext) {
        seedExercises(context)
        seedTemplates(context)
        try? context.save()
    }

    @MainActor
    private static func seedExercises(_ context: ModelContext) {
        let count = (try? context.fetchCount(FetchDescriptor<Exercise>())) ?? 0
        guard count == 0 else { return }

        // Every lift starts at an empty 45 lb bar and goes up 5 lb each time.
        for (index, name) in defaultLiftNames.enumerated() {
            context.insert(
                Exercise(name: name,
                         defaultWeightLb: 45,
                         incrementLb: 5,
                         sortOrder: index)
            )
        }
    }

    @MainActor
    private static func seedTemplates(_ context: ModelContext) {
        let count = (try? context.fetchCount(FetchDescriptor<WorkoutTemplate>())) ?? 0
        guard count == 0 else { return }

        for (index, template) in defaultTemplates.enumerated() {
            context.insert(
                WorkoutTemplate(name: template.0,
                                exerciseNames: template.1,
                                sortOrder: index)
            )
        }
    }
}
