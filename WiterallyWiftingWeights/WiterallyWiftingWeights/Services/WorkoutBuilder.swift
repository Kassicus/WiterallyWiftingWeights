//
//  WorkoutBuilder.swift
//  WiterallyWiftingWeights
//

import Foundation
import SwiftData

enum WorkoutBuilder {
    /// Add an exercise to a session, generating its sets at the progression-
    /// suggested weight.
    @MainActor
    @discardableResult
    static func addExercise(_ exercise: Exercise,
                            to session: WorkoutSession,
                            context: ModelContext) -> LoggedExercise {
        let weight = Progression.suggestedWeightLb(for: exercise, excluding: session)
        let order = (session.exercises.map(\.sortOrder).max() ?? -1) + 1

        let logged = LoggedExercise(exerciseName: exercise.name,
                                    weightLb: weight,
                                    targetReps: exercise.targetReps,
                                    targetSets: exercise.targetSets,
                                    sortOrder: order)
        context.insert(logged)
        logged.exercise = exercise
        logged.session = session

        for number in 1...max(1, exercise.targetSets) {
            let set = SetEntry(setNumber: number, targetReps: exercise.targetReps)
            context.insert(set)
            set.loggedExercise = logged
        }

        return logged
    }
}
